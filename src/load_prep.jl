function get_realization(n::Integer, prep_fn = "prep.h5")
    habitat = load_realization(prep_fn, "habitat", n)
    movement = load_movement(prep_fn, "movement", n)
    init_pop = load_spatial_eq(prep_fn, "spatial_eq", n)
    comm_catchability = load_realization(prep_fn, "catchability_devs", n)
    log_qdevs = load_realization(prep_fn, "log_catchability_devs", n)

    habitat, movement, init_pop, comm_catchability, log_qdevs
end

struct SpatQSimPrep{M, P, Q}
    movement::M
    init_pop::P
    log_qdevs::Q
    realization::Int
    prep_file::String

    function SpatQSimPrep(realization::Int, prep_file::String)
        _, movement, init_pop, _, log_qdevs =
            get_realization(realization, prep_file)
        # Don't need to convert these; taken care of by `get_realization`
        # calling relevant load function movement = MovementModel(movement)
        # init_pop = PopState(init_pop)
        M = typeof(movement)
        P = typeof(init_pop)
        Q = typeof(log_qdevs)
        new{M, P, Q}(movement,
                     init_pop,
                     log_qdevs,
                     realization,
                     prep_file)
    end
end

movement(prep::SpatQSimPrep) = prep.movement
init_pop(prep::SpatQSimPrep) = prep.init_pop
log_qdevs(prep::SpatQSimPrep) = prep.log_qdevs
realization(prep::SpatQSimPrep) = prep.realization
prep_file(prep::SpatQSimPrep) = prep.prep_file
