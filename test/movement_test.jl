@testset "Movement" begin
    specs = [QDevScalingSpec(11, 0.1),
             SharedQSpec(12, 0.4),
             PrefIntensitySpec(13, 4),
             DensityDependentQSpec(4, 1.0),
             HabQSpec(15, 2.0),
             BycatchSpec(16, 0.6)]
    habs = load_habitat.(specs)

    movs = MovementModel.(habs, specs)
    p0s = init_pop.(movs)

    save.(movs, specs)
    save.(p0s, specs)
    mov2 = load_movement(specs[3])

    @test size(movs[3].M) == (10_000, 10_000)
    @test movs[3].M == mov2.M
end
