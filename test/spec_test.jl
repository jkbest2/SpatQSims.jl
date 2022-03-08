@testset "Specs" begin
    specs = [QDevScalingSpec(1, 0.1),
             SharedQSpec(2, 0.4),
             PrefIntensitySpec(3, 4),
             DensityDependentQSpec(4, 1.0),
             HabQSpec(5, 2.0),
             BycatchSpec(6, 0.6)]
    svals = [0.1, 0.4, 4, 1.0, 2.0, 0.6]
 pfns = ["qdevscaling/repl_01/qdevscale_prep.h5",
            "sharedq/repl_02/sharedq_prep.h5",
            "prefintensity/repl_03/prefintensity_prep.h5",
            "densdepq/repl_04/densdepq_prep.h5",
            "habq/repl_05/habq_prep.h5",
            "bycatch/repl_06/bycatch_prep.h5"]

    for idx in 1:length(specs)
        @test realization(specs[idx]) == idx
        @test sim_value(specs[idx]) == svals[idx]
        @test prep_file(specs[idx]) == pfns[idx]
    end
end
