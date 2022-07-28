@testset "Habitat" begin
    specs = [QDevScalingSpec(11, 0.1),
             SharedQSpec(12, 0.4),
             PrefIntensitySpec(13, 4),
             DensityDependentQSpec(4, 1.0),
             HabQSpec(15, 2.0),
             BycatchSpec(16, 0.6),
             MoveRateSpec(17, 100.0)]
    make_repl_dir.(specs)
    habspecs = HabitatSpec.(specs)
    habs = rand.(habspecs)

    save.(habs, specs)
    habs_loaded = load_habitat.(specs)

    for idx in 1:length(specs)
        @test isfile(prep_file(specs[idx]))
        for hdx in 1:length(habspecs[idx])
            @test eltype(habs[idx][hdx]) == habtypes(habspecs[idx])[hdx]
            @test habs[idx].habs == habs_loaded[idx].habs
        end
    end
end
