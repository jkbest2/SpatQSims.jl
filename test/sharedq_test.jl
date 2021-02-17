@testset "Shared catchability" begin
    run_sharedq_sim(1, "prep.h5")

    # Construct all of the expected output file names
    output_files = joinpath.("sharedq",
                             "repl_01",
                             "sharedq_" .*
                             string.(1:length(qdev_scales()), pad = 2) .*
                             ["_popstate.h5" "_popstate.csv" "_catch.csv"])

    @test isdir("sharedq")
    @test isdir("sharedq", "repl_01")
    @test all(isfile.(output_files))
end
