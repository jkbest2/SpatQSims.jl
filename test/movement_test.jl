@testset "Movement" begin
    spec = HabQSpec(5, 2.0)
    hab = load_habitat(spec)

    mov = MovementModel(hab, spec)

    save(mov, spec)
    mov2 = load_movement(spec)

    @test size(mov.M) == (10_000, 10_000)
    @test mov.M == mov2.M
end
