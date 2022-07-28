@testset "Movement" begin
    specs = [QDevScalingSpec(11, 0.1),
             SharedQSpec(12, 0.4),
             PrefIntensitySpec(13, 4),
             DensityDependentQSpec(4, 1.0),
             HabQSpec(15, 2.0),
             BycatchSpec(16, 0.6),
             MoveRateSpec(17, 100.0),
             MoveRateSpec(17, 25.0)]
    habs = load_habitat.(specs)

    @test length(habs[7]) == length(habs[8])
    for idx in 1:length(habs[7])
        @test habs[7][idx] == habs[8][idx]
    end

    movs = MovementModel.(habs, specs)
    p0s = init_pop.(movs)

    save.(movs, specs)
    save.(p0s, specs)

    for idx in 1:8
        @test size(movs[idx].M) == (10_000, 10_000)
        @test movs[idx].M == load_movement(specs[idx]).M
        @test size(p0s[idx].P) == (100, 100)
        # @test p0s[idx].P == load_init_pop(specs[idx]).P
    end
end
