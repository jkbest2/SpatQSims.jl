struct SpatQSimPrep{M, P, Q}
    movement::M
    init_pop::P
    log_qdevs::Q
    realization::Int
    prep_file::String

    function SpatQSimPrep(realization::Int, prep_file::String)
        _, movement, init_pop, _, log_qdevs =
            get_realization(realization, prep_file)
        movement = MovementModel(movement)
        init_pop = PopState(init_pop)
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
