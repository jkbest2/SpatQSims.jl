using SpatQSims
using Test

@testset "SpatQSims.jl" begin
    base_dir = mktempdir()
    cd(base_dir) do
        prep_sims(1, "prep.h5")
        @test "prep.h5" in readdir()

        include("qdevscaling_test.jl")
        include("sharedq_test.jl")
        include("prefintensity_test.jl")
        include("densdepq_test.jl")
        include("habq_test.jl")
    end
end
