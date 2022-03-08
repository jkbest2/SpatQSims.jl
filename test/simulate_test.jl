@testset "Simulate" begin
    csv = true
    feather = true

    spec = BycatchSpec(1, 0.4)
    setup = SpatQSimSetup(spec; load_saved_setup = true)

    result = simulate(setup)
    save(result; csv = csv, feather = feather)

    @test !result_saved(PrefIntensitySpec(100, 4))
    @test result_saved(spec; csv = csv, feather = feather)
end
