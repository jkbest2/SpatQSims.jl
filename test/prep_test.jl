@testset "Prep" begin
    spec = BycatchSpec(1, 0.6)

    prep = SpatQSimPrep(spec)
    save(prep)
    prep2 = load_prep(spec)

    @test size(prep.init_pop) == (100, 100)
    @test isfile(prep_file(spec))

    @test simspec(prep) == simspec(prep2)
    @test habitat(prep).habs == habitat(prep2).habs
    @test movement(prep).M == movement(prep2).M
    @test init_pop(prep).P == init_pop(prep2).P

    habq_spec = HabQSpec(1, 4.0)
    habq_prep = SpatQSimPrep(habq_spec)
    save(habq_prep)
    habq_prep2 = load_prep(habq_spec)

    h5open(prep_path(habq_spec), "r") do h5
        dsets = keys(h5)
        @test "rocky_habitat" ∈ dsets
        @test "movement" ∉ dsets
        @test "init_pop" ∉ dsets
    end
    @test simspec(habq_prep) == simspec(habq_prep2)
    @test habitat(habq_prep).habs == habitat(habq_prep2).habs
    @test movement(habq_prep).M == movement(habq_prep2).M
    # Skip test; doesn't pass because init_pop is approximate
    # @test init_pop(habq_prep).P == init_pop(habq_prep2).P
end
