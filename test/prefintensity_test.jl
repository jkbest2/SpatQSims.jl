@testset "Preference intensity" begin
    run_sims(PrefIntensitySpec, 1;
             prep_file = "prep.h5",
             csv = true,
             feather = true)

    # Construct all of the expected output file names
    output_files = joinpath.("prefintensity",
                             "repl_01",
                             "prefintensity_" .*
                             string.(1:length(sim_values(PrefIntensitySpec)),
                                     pad = 2) .*
                             ["_popstate.h5" "_popstate.csv" "_catch.csv" "_popstate.feather" "_catch.feather"])

    @test isdir("prefintensity")
    @test isdir("prefintensity", "repl_01")
    @test all(isfile.(output_files))
end
