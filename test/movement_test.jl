@testset "Movement" begin
    spec = HabQSpec(25, 2.0)
    make_repl_dir(spec)
    hab = load_habitat(spec)

    mov = MovementModel(hab, spec)

    save(mov, spec)
    mov2 = load_movement(spec)

    @test size(mov.M) == (10_000, 10_000)
    @test mov.M == mov2.M
end
