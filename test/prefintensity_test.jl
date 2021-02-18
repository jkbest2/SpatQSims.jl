@testset "Preference intensity" begin
    run_prefintensity_sim(1, "prep.h5")

    # Construct all of the expected output file names
    output_files = joinpath.("prefintensity",
                             "repl_01",
                             "prefintensity_" .*
                             string.(1:length(qdev_scales()), pad = 2) .*
                             ["_popstate.h5" "_popstate.csv" "_catch.csv"])

    @test isdir("prefintensity")
    @test isdir("prefintensity", "repl_01")
    @test all(isfile.(output_files))
end
