struct QDevScalingSpec{T} <: SpatQSimSpec
    realization::Int
    qdev_scale::T
    prep_file::String

    function QDevScalingSpec(realization::Int,
                             qdev_scale::T,
                             prep_file::String = "prep.h5") where T
        new{T}(realization, qdev_scale, prep_file)
    end
end

sim_value(spec::QDevScalingSpec) = spec.qdev_scale

comm_qdev_scale(spec::QDevScalingSpec) = sim_value(spec)

# qdev_scales() = 10.0 .^ (-5:-1)

# function qdev_scale_idx(spec::QDevScalingSpec)
#     findfirst(isapprox(spec.qdev_scale),
#               qdev_scales())
# end

# function simstudy_dir(spec::QDevScalingSpec; base_dir = ".")
#     joinpath(base_dir, "qdevscaling")
# end

# """
#     file_paths(spec::QDevScalingSpec)

# Returns paths for population state HDF5 array, population total CSV, and catch
# CSV. Will create directories as needed. For example, for the 5th realization
# using the second catchability deviation scaling factor, this function will
# return:

#     repl_05/qdevscale_2_popstate.h5
#     repl_05/qdevscale_2_popstate.csv
#     repl_05/qdevscale_2_catch.csv
# """
# function file_paths(spec::QDevScalingSpec; base_dir = ".")
#     rlz = realization(spec)

#     base_dir = joinpath(simstudy_dir(spec; base_dir = base_dir),
#                          "repl_" * string(rlz, pad = 2))
#     if !isdir(base_dir)
#         mkpath(base_dir)
#     end

#     file_base = joinpath(base_dir,
#                          "qdevscale_" * string(qdev_scale_idx(spec), pad = 2))
#     file_base .* ["_popstate.h5",
#                   "_popstate.csv",
#                   "_catch.csv"]
# end

# """
#     run_qdevscaling_sim(n_repl::Int = 100, prep_file = "prep.h5")

# Simulate `n_repl` replicates of a fishery with different magnitudes of spatial
# variation in catchability for the commercial fleet (defined in the function
# `qdev_scales`).
# """
# function run_qdevscaling_sim(n_repl::Int = 100, prep_file = "prep.h5")
#     qdev_scale_vec = qdev_scales()
#     for rlz in 1:n_repl
#         for sc in qdev_scale_vec
#             spec = QDevScalingSpec(rlz, sc, prep_file)
#             setup = SpatQSimSetup(spec)
#             result = simulate(setup)
#             save(result)
#         end
#     end
#     nothing
# end
