struct SpatQSimPrep{M, P, Q, F}
    realization::Int
    movement::M
    init_pop::P
    log_qdevs::Q
    prep_file::F

    function SpatQSimPrep(realization::Int,
                          movement::M,
                          init_pop::P,
                          log_qdevs::Q,
                          prep_file::F = nothing) where {M<:Movement,
                                                         P<:PopState,
                                                         Q<:Matrix,
                                                         F<:Union{String, Nothing}}
        new{M, P, Q, F}(realization, movement, init_pop, log_qdevs, prep_file)
    end
end

function SpatQSimPrep(realization::Int, prep_file::String)
    _, movement, init_pop, _, log_qdevs =
        get_realization(realization, prep_file)
    movement = MovementModel(movement)
    init_pop = PopState(init_pop)
    M = typeof(movement)
    P = typeof(init_pop)
    Q = typeof(log_qdevs)
    F = typeof(prep_file)
    new{M, P, Q, F}(realization,
                    movement,
                    init_pop,
                    log_qdevs,
                    prep_file)
end

movement(prep::SpatQSimPrep) = prep.movement
init_pop(prep::SpatQSimPrep) = prep.init_pop
log_qdevs(prep::SpatQSimPrep) = prep.log_qdevs
realization(prep::SpatQSimPrep) = prep.realization
prep_file(prep::SpatQSimPrep) = prep.prep_file
