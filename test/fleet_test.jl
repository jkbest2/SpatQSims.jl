@testset "Vessels & Fleets" begin
    specs = [QDevScalingSpec(1, 1.0),
             SharedQSpec(2, 0.5),
             PrefIntensitySpec(3, 2.0),
             DensityDependentQSpec(4, 3.0),
             HabQSpec(5, 2.0),
             BycatchSpec(6, 0.5)]
    preps = SpatQSimPrep.(specs)
    fleets = fleet.(preps)

    # Not sure what to test here, but at least I'll know everything runs
    @test length(fleets) == 6
end
