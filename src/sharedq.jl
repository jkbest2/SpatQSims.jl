struct SharedQSpec{T} <: SpatQSimSpec
    realization::Int
    share_scale::T
    prep_file::String

    function SharedQSpec(realization::Int,
                         share_scale::T,
                         prep_file::String = "prep.h5") where T
        new{T}(realization, share_scale, prep_file)
    end
end

# share_scales() = 0:0.2:1
# share_scale_idx(spec::SharedQSpec) = findfirst(isapprox(spec.share_scale),
#                                                share_scales())

sim_value(spec::SharedQSpec) = spec.share_scale
# survey_qdev_scale(spec::SharedQSpec) = spec.share_scale
function survey_catchability(spec::SharedQSpec, prep::SpatQSimPrep)
    qdevs = transform_log_qdevs(log_qdevs(prep),
                                sim_value(spec) * comm_qdev_scale(spec))
    Catchability(base_catchability().catchability .* qdevs)
end

# function simstudy_dir(spec::SharedQSpec; base_dir = ".")
#     joinpath(base_dir, "sharedq")
# end

# """
#     file_paths(spec::SharedQSpec)

# Returns paths for population state HDF5 array, population total CSV, and catch
# CSV. Will create directories as needed. For example, for the 5th realization
# using the second catchability deviation scaling factor, this function will
# return:

#     repl_05/sharedq_02_popstate.h5
#     repl_05/sharedq_02_popstate.csv
#     repl_05/sharedq_02_catch.csv
# """
# function file_paths(spec::SharedQSpec; base_dir = ".")
#     rlz = realization(spec)

#     base_dir = joinpath(simstudy_dir(spec; base_dir = base_dir),
#                          "repl_" * string(rlz, pad = 2))
#     if !isdir(base_dir)
#         mkpath(base_dir)
#     end

#     file_base = joinpath(base_dir,
#                          "sharedq_" * string(share_scale_idx(spec), pad = 2))
#     file_base .* ["_popstate.h5",
#                   "_popstate.csv",
#                   "_catch.csv"]
# end

# """
#     run_sharedq_sim(n_repl::Int = 100, prep_file = "prep.h5")

# Simulate `n_repl` replicates of a fishery with different magnitudes of spatial
# variation in catchability for the commercial fleet (defined in the function
# `qdev_scales`).
# """
# function run_sharedq_sim(n_repl::Int = 100, prep_file = "prep.h5")
#     share_scale_vec = share_scales()
#     for rlz in 1:n_repl
#         for sc in share_scale_vec
#             spec = SharedQSpec(rlz, sc, prep_file)
#             setup = SpatQSimSetup(spec)
#             result = simulate(setup)
#             save(result)
#         end
#     end
#     nothing
# end
