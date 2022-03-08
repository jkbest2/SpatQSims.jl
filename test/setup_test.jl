@testset "Setup" begin
    spec = BycatchSpec(1, 0.4)
    setup = SpatQSimSetup(spec; load_saved_prep = true)

    @test simspec(setup) == spec
    @test init_pop(setup) isa PopState
    @test fleet(setup) isa Fleet
    @test movement(setup) isa MovementModel
    @test pop_dynamics(setup) isa PopulationDynamicsModel
    @test domain(setup) == SpatQSims.SIM_DOMAIN
    @test n_years(setup) == SpatQSims.SIM_NYEARS
end
