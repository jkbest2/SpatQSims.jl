module SpatQSims

using FisherySim
using Distributions
using Plots
using Random
using HDF5
using CSV
using StructArrays

import Plots: plot

include("realizations.jl")
include("prep_sims.jl")
include("scale_devs.jl")
include("plots.jl")

export
    prep_sims,
    get_realization,
    run_simulation,
    run_scenarios,
    save_scenarios,
    generate_realizations,
    save_realizations,
    load_realization,
    load_movement,
    load_spatial_eq,
    load_popstate,
    scale_devs,
    catch_by_year,
    plot_gif,
    plot,
    get_coordref,
    write_coordref

function get_realization(n::Integer, prep_fn = "prep.h5")
    habitat = load_realization(prep_fn, "habitat", n)
    movement = load_movement(prep_fn, "movement", n)
    init_pop = load_spatial_eq(prep_fn, "spatial_eq", n)
    comm_catchability = load_realization(prep_fn, "catchability_devs", n)
    log_catchability_devs = load_realization(prep_fn, "log_catchabilty_devs", n)

    habitat, movement, init_pop, comm_catchability, log_catchability_devs
end

function run_simulation(scenario::Symbol,
                        realization::Integer,
                        prep_fn = "prep.h5")
    # Don't need habitat for simulation
    _, movement, init_pop, catchability_devs =
        get_realization(realization, prep_fn)

    # 100×100 gridded domain for all simulations
    Ω = GriddedFisheryDomain()

    #-Population dynamics-------------------------------------------------------
    r = 0.06
    K = 100.0

    # K defined above to get spatial equilibrium
    schaefer = Schaefer(r, K)

    #-Targeting-----------------------------------------------------------------
    # Commercial targeting depends on population, so isn't constructed prior to
    # simulation.
    survey_stations = vec(LinearIndices(Ω.n)[2:4:98, 5:10:95])
    survey_targeting = FixedTargeting(survey_stations)
    # Commercial preference is based on spatial distribution of biomass
    comm_targeting = DynamicPreferentialTargeting(init_pop.P, identity)

    #-Catchability--------------------------------------------------------------
    survey_q_base = 0.2
    comm_q_base = 0.2
    if scenario == :pref
        survey_catchability = Catchability(survey_q_base)
        comm_catchability = Catchability(comm_q_base)
    elseif scenario == :spat
        survey_catchability = Catchability(survey_q_base)
        comm_catchability = Catchability(comm_q_base .* catchability_devs)
        comm_targeting = RandomTargeting()
    elseif scenario == :combo
        survey_catchability = Catchability(survey_q_base)
        comm_catchability = Catchability(comm_q_base .* catchability_devs)
    else
        @error "scenario must be one of :pref, :spat, or :combo."
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
                   2_500])

    #-Simulate------------------------------------------------------------------
    simulate(init_pop, fleet, movement, schaefer, Ω, 25)
end

function run_scenarios(repl::Integer, flnm = "prep.h5")
    Pdict = Dict{Symbol, Vector{PopState}}()
    Cdict = Dict{Symbol, Vector{Catch}}()
    for sc in [:pref, :spat, :combo]
        P, C = run_simulation(sc, repl, flnm)
        push!(Pdict, sc => P)
        push!(Cdict, sc => C)
    end
    Pdict, Cdict
end

function save_scenarios(repl::Integer, Pdict, Cdict)
    mkpath("repl_" * string(repl, pad = 2))
    cd("repl_" * string(repl, pad = 2)) do
        # Save population states to HDF5 file
        flnm = "pop_" * string(repl, pad = 2) * ".h5"
        dom_size = size(Pdict[:pref][1])
        time_size = length(Pdict[:pref])
        h5open(flnm, "w") do fid
            for sc in keys(Pdict)
                sc_grp = g_create(fid, string(sc))
                sc_pop = d_create(sc_grp, "popstate", datatype(Float64),
                                  dataspace(dom_size..., time_size))
                for yr in eachindex(Pdict[sc])
                    sc_pop[:, :, yr] = Pdict[sc][yr].P
                end
            end
        end

        for sc in keys(Pdict)
            popstate = (pop = sum.(Pdict[sc]),)
            CSV.write("popstate_" * string(repl, pad = 2) *
                      "_" * string(sc) * ".csv",
                      StructArray(popstate))
        end

        # Save catch records to CSV file
        for sc in keys(Cdict)
            flnm = "catch_" * string(repl, pad = 2) *
                  "_" * string(sc) * ".csv"
            CSV.write(flnm, StructArray(Cdict[sc]))
        end
    end
    nothing
end

function get_coordref(Ω)
    [(loc_idx = i, s1 = s1, s2 = s2)
        for (i, (s1, s2)) in enumerate(vec(Ω.locs))]
end

function write_coordref(Ω)
    coordref = get_coordref(Ω)
    CSV.write("coordref.csv", coordref)
end

end # module
