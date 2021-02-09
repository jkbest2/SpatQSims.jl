@testset "Catchability Deviation scaling" begin
    base_dir = mktempdir()
    cd(base_dir) do
        prep_sims(1, "prep.h5")
        run_qdevscaling_sim(1, "prep.h5")

        # Construct all of the expected output file names
        output_files = joinpath.("qdevscaling",
                                 "repl_01",
                                 "qdevscale_" .*
                                 string.(1:length(qdev_scales()), pad = 2) .*
                                 ["_popstate.h5" "_popstate.csv" "_catch.csv"])

        @test "prep.h5" in readdir()
        @test isdir("qdevscaling")
        @test isdir("qdevscaling", "repl_01")
        @test all(isfile.(output_files))
    end
end
