module SpatQSims

using FisherySim
using Distributions
using Plots
using Random
using HDF5

import Plots: plot

include("realizations.jl")
include("scale_devs.jl")
include("plots.jl")

export
    prep_sims,
    get_realization,
    run_simulation,
    generate_realizations,
    save_realizations,
    load_realization,
    load_movement,
    load_popstate,
    scale_devs,
    catch_by_year,
    plot_gif,
    plot

function prep_sims(n = 100, prep_fn = "prep.h5", K = 100.0)
    # Set seed for reproducibility. Passing RNGs directly doesn't work yet.
    Random.seed!(2020)

    # Use 100×100 gridded fishery domain for all simulations
    Ω = GriddedFisheryDomain()

    #-Habitat-------------------------------------------------------------------
    # Declare habitat distribution
    habitat_kernel = Matérn32Cov(4.0, 30.0)
    hab_mean_fn(loc) = cospi(loc[1] / 50.0) + cospi(loc[2] / 50.0)
    habitat_mean = 2hab_mean_fn.(Ω.locs)
    habitat_cov = cov(habitat_kernel, Ω)
    habitat_distribution = DomainDistribution(MvNormal(vec(habitat_mean),
                                                       habitat_cov), Ω)

    #-Movement------------------------------------------------------------------
    # Declare habitat preference function and plot realized preference
    hab_pref_fn(h) = exp(-(h + 5)^2 / 40)
    # Distance travelled in a single step decays exponentially
    distance_fn(d) = exp(-d / 1)

    #-Vessels-------------------------------------------------------------------
    # Catchability deviations - spatially correlated multiplicative noise
    catchability_devs_kern = Matérn32Cov(0.05, 30.0)
    catchability_devs_cov = cov(catchability_devs_kern, Ω)
    catchability_devs_distr = DomainDistribution(MvLogNormal,
                                                 ones(length(Ω)),
                                                 catchability_devs_cov, Ω)

    h5open(prep_fn, "w") do fid
        hab_dset = d_create(fid, "habitat", datatype(Float64),
                            dataspace(size(Ω)..., n),
                            "chunk", (size(Ω)..., 1))
        mov_dset = d_create(fid, "movement", datatype(Float64),
                            dataspace(length(Ω), length(Ω), n),
                            "chunk", (size(Ω)..., 1))
        speq_dset = d_create(fid, "spatial_eq", datatype(Float64),
                             dataspace(size(Ω)..., n),
                             "chunk", (size(Ω)..., 1))
        qdev_dset = d_create(fid, "catchability_devs", datatype(Float64),
                             dataspace(size(Ω)..., n),
                             "chunk", (size(Ω)..., 1))

        hab = zeros(size(Ω)...)
        mov = zeros(length(Ω), length(Ω))
        speq = zeros(size(Ω)...)
        qdev = zeros(size(Ω)...)

        for rlz in 1:n
            # Generate habitats and save
            hab .= rand(habitat_distribution)
            hab_dset[:, :, rlz] = hab

            # Derive movement operator and save
            mov .= MovementModel(Ω, hab, hab_pref_fn, distance_fn).M
            mov_dset[:, :, rlz] = mov

            # Find spatial equilibium distribution and save
            speq .= approx_eqdist(MovementModel(mov, size(Ω)), K).P
            speq_dset[:, :, rlz] = speq

            # Generate spatially correlated catchability deviations
            qdev .= rand(catchability_devs_distr)
            qdev_dset[:, :, rlz] = qdev
        end
    end

    # Return nothing; everything else accessed via saved HDF5 files
    nothing
end

function get_realization(n::Integer, prep_fn = "prep.h5")
    habitat = load_realization(prep_fn, "habitat", n)
    movement = load_movement(prep_fn, "movement", n)
    init_pop = load_popstate(prep_fn, "spatial_eq", n)
    comm_catchability = load_realization(pref_fn, "catchability_deviations", n)

    habitat, movement, init_pop, comm_catchability
end

function run_simulation(q_scenario::Symbol,
                        realization::Integer,
                        prep_fn = "prep.h5")
    # Don't need habitat for simulation
    _, movement, init_pop, catchability_devs =
        get_realization(realization, prep_fn)

    # 100×100 gridded domain for all simulations
    Ω = GriddedFisheryDomain()

    #-Population dynamics-------------------------------------------------------
    r = 0.2
    K = 100.0

    # K defined above to get spatial equilibrium
    schaefer = Schaefer(r, K)

    #-Targeting-----------------------------------------------------------------
    # Commercial targeting depends on population, so isn't constructed prior to
    # simulation.
    survey_stations = vec(LinearIndices(Ω.n)[2:2:98, 5:10:95])
    survey_targeting = FixedTargeting(survey_stations)
    # Commercial preference is based on spatial distribution of biomass
    comm_targeting = DynamicPreferentialTargeting(init_pop.P, identity)
    
    #-Catchability--------------------------------------------------------------
    survey_q_base = 0.2
    comm_q_base = 0.2
    if q_scenario == :naive
        # No spatially varying catchability in either fleet
        survey_catchability = survey_q_base
        comm_catchability = comm_q_base
    elseif q_scenario == :simple
        # Only commercial vessels have spatial catchability
        survey_catchability = survey_q_base
        comm_catchability = comm_q_base .* catchability_devs
    elseif q_scenario == :scaled
        # Both, but scaled down for survey
        survey_catchability = survey_q_base .* scale_devs.(catchability_devs)
        comm_catchability = comm_q_base .* catchability_devs
    elseif q_scenario == :shared
        # Shared
        survey_catchability = survey_q_base .* catchability_devs
        comm_catchability = comm_q_base .* catchability_devs
    else
        @error "q_scenario must be one of :naive, :simple, :scaled, or :shared."
    end

    #-Vessels-------------------------------------------------------------------
    # Tweedie power parameter
    ξ = 1.84
    # Tweedie variance parameter
    ϕ = 1.2
    survey_vessel = Vessel(survey_targeting,
                           survey_catchability,
                           ξ, ϕ)
    comm_vessel = Vessel(comm_targeting,
                         comm_catchability,
                         ξ, ϕ)

    #-Fleet---------------------------------------------------------------------
    fleet = Fleet([survey_vessel, comm_vessel],
                  [length(survey_vessel.target.locations),
                   10_000])

    #-Simulate------------------------------------------------------------------
    simulate(init_pop, fleet, movement, schaefer, Ω, 25)
end

function get_coord_reference(Ω)
    coord_reference = [(idx = i, s1 = s1, s2 = s2) for
                       (i, (s1, s2)) in enumerate(vec(Ω.locs))]
end

function write_coord_reference()
    coord_reference = get_coord_reference()
    CSV.write("coord_reference.csv", coord_reference)
end

end # module
