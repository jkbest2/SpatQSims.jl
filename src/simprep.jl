# function get_realization(n::Integer, prep_fn = "prep.h5")
#     habitat = load_realization(prep_fn, "habitat", n)
#     movement = load_movement(prep_fn, "movement", n)
#     init_pop = load_spatial_eq(prep_fn, "spatial_eq", n)
#     comm_catchability = load_realization(prep_fn, "catchability_devs", n)
#     log_qdevs = load_realization(prep_fn, "log_catchability_devs", n)

#     habitat, movement, init_pop, comm_catchability, log_qdevs
# end

# struct SpatQSimPrep{M, P, Q, F}
#     realization::Int
#     movement::M
#     init_pop::P
#     log_qdevs::Q
#     prep_file::F

#     function SpatQSimPrep(realization::Int,
#                           movement::M,
#                           init_pop::P,
#                           log_qdevs::Q,
#                           prep_file::F = nothing) where {M<:MovementModel,
#                                                          P<:PopState,
#                                                          Q<:Matrix,
#                                                          F<:Union{String, Nothing}}
#         new{M, P, Q, F}(realization, movement, init_pop, log_qdevs, prep_file)
#     end
# end

# function SpatQSimPrep(realization::Int, prep_file::String)
#     _, movement, init_pop, _, log_qdevs =
#         get_realization(realization, prep_file)
#     SpatQSimPrep(realization, movement, init_pop, log_qdevs, prep_file)
# end

# movement(prep::SpatQSimPrep) = prep.movement
# init_pop(prep::SpatQSimPrep) = prep.init_pop
# log_qdevs(prep::SpatQSimPrep) = prep.log_qdevs
# realization(prep::SpatQSimPrep) = prep.realization
# prep_file(prep::SpatQSimPrep) = prep.prep_file
