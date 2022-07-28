@testset "Simulate" begin
    csv = true
    feather = true

    # Single-simulation tests
    spec = BycatchSpec(1, 0.6)
    setup = SpatQSimSetup(spec; load_saved_prep=true)
    result = simulate(setup)
    save(result; csv=csv, feather=feather)

    # Multi-sim tests, should skip Bycatch simulated above
    specs = [QDevScalingSpec(1, 0.1),
             SharedQSpec(2, 0.4),
             PrefIntensitySpec(3, 4),
             DensityDependentQSpec(4, 1.0),
             HabQSpec(5, 2.0),
             BycatchSpec(6, 0.6),
             MoveRateSpec(7, 100.0)]
    results = run_sims(specs;
                       checkpoint=true,
                       csv=csv,
                       feather=feather)

    @test isfile(prep_path(spec))
    @test !result_saved(PrefIntensitySpec(100, 4))
    @test result_saved(spec; csv=csv, feather=feather)

    for spec in specs
        @test isfile(prep_path(spec))
        @test result_saved(spec; csv=csv, feather=feather)
    end

    # Check that BycatchSpec simulation happened before any of the others to
    # make sure that checkpointing worked
    byc_mtime = mtime(file_paths(spec)[:pop_h5])
    qd_mtime = mtime(file_paths(specs[1])[:pop_h5])
    @test byc_mtime < qd_mtime
end
