@testset "Catchability Deviation scaling" begin
    run_sims(QDevScalingSpec, 1;
             prep_file = "prep.h5",
             csv = true,
             feather = true)

    # Construct all of the expected output file names
    output_files = joinpath.("qdevscaling",
                             "repl_01",
                             "qdevscale_" .*
                             string.(1:length(sim_values(QDevScalingSpec)),
                                     pad = 2) .*
                             ["_popstate.h5" "_popstate.csv" "_catch.csv" "_popstate.feather" "_catch.feather"])

    @test isdir("qdevscaling")
    @test isdir("qdevscaling", "repl_01")
    @test all(isfile.(output_files))
end
