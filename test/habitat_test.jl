@testset "Habitat" begin
    specs = [QDevScalingSpec(1, 1.0),
             SharedQSpec(2, 0.5),
             PrefIntensitySpec(3, 2.0),
             DensityDependentQSpec(4, 3.0),
             HabQSpec(5, 2.0),
             BycatchSpec(6, 0.5)]
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
