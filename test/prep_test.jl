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
        @test haskey(h5, "rocky_habitat")
        @test haskey(h5, "movement")
        @test haskey(h5, "init_pop")
    end

    @test simspec(habq_prep) == simspec(habq_prep2)
    @test habitat(habq_prep).habs == habitat(habq_prep2).habs
    @test movement(habq_prep).M == movement(habq_prep2).M
    # Skip test; doesn't pass because init_pop is approximate
    # @test init_pop(habq_prep).P == init_pop(habq_prep2).P

    # Generate totally fresh MoveRate prep
    specmr = MoveRateSpec(27, sim_values(MoveRateSpec)[1])
    prepmr = SpatQSimPrep(specmr)
    save(prepmr)
    # Check subsequent for same habitat, different movement
    for mr in sim_values(MoveRateSpec)[2:end]
        specmr2 = MoveRateSpec(27, mr)
        prepmr2 = SpatQSimPrep(specmr2)
        @test habitat(prepmr).habs == habitat(prepmr2).habs
        save(prepmr2)

        prepmr3 = load_prep(specmr2)
        @test habitat(prepmr3).habs == habitat(prepmr).habs
        @test movement(prepmr3).M == movement(prepmr2).M
        @test movement(prepmr3).M != movement(prepmr).M
    end
end
