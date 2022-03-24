using SpatQSims
using FisherySim
using HDF5
using Test

@testset "SpatQSims.jl" begin
    base_dir = mktempdir()
    cd(base_dir) do
        include("spec_test.jl")
        include("habitat_test.jl")
        include("movement_test.jl")
        include("prep_test.jl")
        include("fleet_test.jl")
        include("setup_test.jl")
        include("simulate_test.jl")
    end
end
