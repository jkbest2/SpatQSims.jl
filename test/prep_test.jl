@testset "Prep" begin
    spec = BycatchSpec(1, 0.4)

    prep = SpatQSimPrep(spec)
    save(prep)
    prep2 = load_prep(spec)

    @test size(prep.init_pop) == (100, 100)
    @test isfile(prep_file(spec))
    # @test prep == prep2
    # @test prep.init_pop == prep2.init_pop
end
