@testset "Shared catchability" begin
    run_sims(SharedQSpec, 1;
             prep_file = "prep.h5",
             csv = true,
             feather = true)

    # Construct all of the expected output file names
    output_files = joinpath.("sharedq",
                             "repl_01",
                             "sharedq_" .*
                             string.(1:length(sim_values(SharedQSpec)),
                                     pad = 2) .*
                             ["_popstate.h5" "_popstate.csv" "_catch.csv" "_popstate.feather" "_catch.feather"])

    @test isdir("sharedq")
    @test isdir("sharedq", "repl_01")
    @test all(isfile.(output_files))
end
