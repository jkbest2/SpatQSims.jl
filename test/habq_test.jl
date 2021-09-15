@testset "Habitat catchability" begin
    habq_spec = HabQSpec(1, 1.0)
    run_sims(HabQSpec, 1;
             base_dir = ".",
             csv = true,
             feather = true)

    # Construct all of the expected output file names
    output_files = joinpath.("habq",
                             "repl_01",
                             "habq_" .*
                             string.(1:length(sim_values(HabQSpec)),
                                     pad = 2) .*
                             ["_popstate.h5" "_popstate.csv" "_catch.csv" "_popstate.feather" "_catch.feather"])

    @test prep_file(habq_spec) == "habq/repl_01/habq_prep.h5"
    @test isdir("habq")
    @test isdir("habq", "repl_01")
    @test all(isfile.(output_files))
end
