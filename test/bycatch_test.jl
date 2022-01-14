@testset "Bycatch avoidance" begin
    bycatch_spec = BycatchSpec(1, 1.0)
    run_sims(BycatchSpec, 1;
             base_dir = ".",
             csv = true,
             feather = true)

    # Construct all of the expected output file names
    output_files = joinpath.("bycatch",
                             "repl_01",
                             "bycatch_" .*
                             string.(1:length(sim_values(BycatchSpec)),
                                     pad = 2) .*
                             ["_popstate.h5" "_popstate.csv" "_catch.csv" "_popstate.feather" "_catch.feather"])

    @test prep_file(bycatch_spec) == "bycatch/repl_01/bycatch_prep.h5"
    @test isdir("bycatch")
    @test isdir("bycatch", "repl_01")
    @test all(isfile.(output_files))
end
