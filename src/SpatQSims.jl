module SpatQSims

using FisherySim
using Distributions
using Plots
using Random
using HDF5
using CSV
using StructArrays
using Arrow

import FisherySim: simulate
import Plots: plot

include("realizations.jl")
export
    generate_realizations,
    save_realizations,
    load_realization,
    load_movement,
    # save_realizations
    load_spatial_eq,
    load_popstate,
    # save_realizations,
    load_cathcability

include("prep_sims.jl")
export
    prep_sims

include("scale_devs.jl")
export
    scale_devs,
    transform_log_qdevs

include("simprep.jl")
export
    get_realization,
    SpatQSimPrep,
    movement,
    init_pop,
    log_qdevs,
    realization,
    prep_file

include("simspec.jl")
export
    SpatQSimSpec,
    # realization,
    # prep_file,
    domain,
    pop_dynamics,
    survey_targeting,
    comm_targeting,
    base_catchability,
    survey_catchability,
    comm_catchability,
    tweedie_shape,
    tweedie_dispersion,
    n_years,
    survey_vessel,
    comm_vessel,
    fleet

include("qdevscaling.jl")
export
    QDevScalingSpec,
    sim_value,
    comm_qdev_scale

include("sharedq.jl")
export
    SharedQSpec,
    sim_value,
    survey_catchability

include("prefintensity.jl")
export
    PrefIntensitySpec,
    sim_value,
    comm_targeting

include("densdepq.jl")
export
    DensityDependentQSpec,
    sim_value,
    comm_catchability

include("sim_pars.jl")
export
    sim_values,
    sim_value_idx

include("files.jl")
export
    file_paths,
    simstudy_dir,
    simstudy_prefix

include("simsetup.jl")
export
    SpatQSimSetup,
    simulate

include("run_sims.jl")
export
    run_sims

include("simresult.jl")
export
    SpatQSimResult,
    # realization,
    file_paths,
    save,
    save_pop_hdf5,
    save_pop_csv,
    save_catch_csv

include("plots.jl")
export
    catch_by_year,
    plot_gif,
    plot

# function run_simulation(scenario::Symbol,
#                         realization::Integer,
#                         prep_fn = "prep.h5")
#     # Don't need habitat for simulation
#     _, movement, init_pop, catchability_devs =
#         get_realization(realization, prep_fn)

#     # 100×100 gridded domain for all simulations
#     Ω = GriddedFisheryDomain()

#     #-Population dynamics-------------------------------------------------------
#     r = 0.06
#     K = 100.0

#     # K defined above to get spatial equilibrium
#     schaefer = Schaefer(r, K)

#     #-Targeting-----------------------------------------------------------------
#     # Commercial targeting depends on population, so isn't constructed prior to
#     # simulation.
#     survey_stations = vec(LinearIndices(Ω.n)[2:4:98, 5:10:95])
#     survey_targeting = FixedTargeting(survey_stations)
#     # Commercial preference is based on spatial distribution of biomass
#     comm_targeting = DynamicPreferentialTargeting(init_pop.P, identity)

#     #-Catchability--------------------------------------------------------------
#     survey_q_base = 0.2
#     comm_q_base = 0.2
#     if scenario == :pref
#         survey_catchability = Catchability(survey_q_base)
#         comm_catchability = Catchability(comm_q_base)
#     elseif scenario == :spat
#         survey_catchability = Catchability(survey_q_base)
#         comm_catchability = Catchability(comm_q_base .* catchability_devs)
#         comm_targeting = RandomTargeting()
#     elseif scenario == :combo
#         survey_catchability = Catchability(survey_q_base)
#         comm_catchability = Catchability(comm_q_base .* catchability_devs)
#     else
#         @error "scenario must be one of :pref, :spat, or :combo."
#     end

#     #-Vessels-------------------------------------------------------------------
#     # Tweedie power parameter
#     ξ = 1.84
#     # Tweedie variance parameter
#     ϕ = 1.2
#     survey_vessel = Vessel(survey_targeting,
#                            survey_catchability,
#                            ξ, ϕ)
#     comm_vessel = Vessel(comm_targeting,
#                          comm_catchability,
#                          ξ, ϕ)

#     #-Fleet---------------------------------------------------------------------
#     fleet = Fleet([survey_vessel, comm_vessel],
#                   [length(survey_vessel.target.locations),
#                    2_500])

#     #-Simulate------------------------------------------------------------------
#     simulate(init_pop, fleet, movement, schaefer, Ω, 25)
# end

# function run_scenarios(repl::Integer, flnm = "prep.h5")
#     Pdict = Dict{Symbol, Vector{PopState}}()
#     Cdict = Dict{Symbol, Vector{Catch}}()
#     for sc in [:pref, :spat, :combo]
#         P, C = run_simulation(sc, repl, flnm)
#         push!(Pdict, sc => P)
#         push!(Cdict, sc => C)
#     end
#     Pdict, Cdict
# end

# function save_scenarios(repl::Integer, Pdict, Cdict)
#     mkpath("repl_" * string(repl, pad = 2))
#     cd("repl_" * string(repl, pad = 2)) do
#         # Save population states to HDF5 file
#         flnm = "pop_" * string(repl, pad = 2) * ".h5"
#         dom_size = size(Pdict[:pref][1])
#         time_size = length(Pdict[:pref])
#         h5open(flnm, "w") do fid
#             for sc in keys(Pdict)
#                 sc_grp = g_create(fid, string(sc))
#                 sc_pop = create_dataset(sc_grp, "popstate", datatype(Float64),
#                                   dataspace(dom_size..., time_size))
#                 for yr in eachindex(Pdict[sc])
#                     sc_pop[:, :, yr] = Pdict[sc][yr].P
#                 end
#             end
#         end

#         for sc in keys(Pdict)
#             popstate = (pop = sum.(Pdict[sc]),)
#             CSV.write("popstate_" * string(repl, pad = 2) *
#                       "_" * string(sc) * ".csv",
#                       StructArray(popstate))
#         end

#         # Save catch records to CSV file
#         for sc in keys(Cdict)
#             flnm = "catch_" * string(repl, pad = 2) *
#                   "_" * string(sc) * ".csv"
#             CSV.write(flnm, StructArray(Cdict[sc]))
#         end
#     end
#     nothing
# end

# function get_coordref(Ω)
#     [(loc_idx = i, s1 = s1, s2 = s2)
#         for (i, (s1, s2)) in enumerate(vec(Ω.locs))]
# end

# function write_coordref(Ω)
#     coordref = get_coordref(Ω)
#     CSV.write("coordref.csv", coordref)
# end

end # module
