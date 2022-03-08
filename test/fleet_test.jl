@testset "Vessels & Fleets" begin
    specs = [QDevScalingSpec(1, 0.1),
             SharedQSpec(2, 0.4),
             PrefIntensitySpec(3, 4),
             DensityDependentQSpec(4, 1.0),
             HabQSpec(5, 2.0),
             BycatchSpec(6, 0.6)]
    preps = SpatQSimPrep.(specs)
    fleets = fleet.(preps)

    # Not sure what to test here, but at least I'll know everything runs
    @test length(fleets) == 6
end
