@testset "Prep" begin
    spec = BycatchSpec(1, 0.4)

    prep = SpatQSimPrep(spec)
    save(prep)
    prep2 = load_prep(spec)

    @test size(prep.init_pop) == (100, 100)
    @test isfile(prep_file(spec))

    @test simspec(prep) == simspec(prep2)
    @test habitat(prep).habs == habitat(prep2).habs
    @test movement(prep).M == movement(prep2).M
    @test init_pop(prep).P == init_pop(prep2).P
end
