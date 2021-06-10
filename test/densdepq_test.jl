@testset "Density-dependent catchability" begin
    run_sims(DensityDependentQSpec, 1;
             prep_file = "prep.h5",
             csv = true,
             feather = true)

    # Construct all of the expected output file names
    output_files = joinpath.("densdepq",
                             "repl_01",
                             "densdepq_" .*
                             string.(1:length(sim_values(DensityDependentQSpec)),
                                     pad = 2) .*
                             ["_popstate.h5" "_popstate.csv" "_catch.csv" "_popstate.feather" "_catch.feather"])

    @test isdir("densdepq")
    @test isdir("densdepq", "repl_01")
    @test all(isfile.(output_files))
end
