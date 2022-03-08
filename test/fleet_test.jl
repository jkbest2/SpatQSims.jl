@testset "Vessels & Fleets" begin
    specs = [QDevScalingSpec(11, 0.1),
             SharedQSpec(12, 0.4),
             PrefIntensitySpec(13, 4),
             DensityDependentQSpec(14, 1.0),
             HabQSpec(15, 2.0),
             BycatchSpec(16, 0.6)]
    preps = SpatQSimPrep.(specs)
    fleets = fleet.(preps)

    # Not sure what to test here, but at least I'll know everything runs
    @test length(fleets) == 6
end
