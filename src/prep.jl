# Constructors ------------------------------------------------------------------
struct SpatQSimPrep{S, H, M, P}
    spec::S
    habitat::H
    movement::M
    init_pop::P

    function SpatQSimPrep(spec::S,
                          habitat::H,
                          movement::M,
                          init_pop::P) where {S<:SpatQSimSpec,
                                              H<:Habitat,
                                              M<:MovementModel,
                                              P<:PopState}
        new{S, H, M, P}(spec, habitat, movement, init_pop)
    end
end

function SpatQSimPrep(spec::SpatQSimSpec)
    habspec = HabitatSpec(spec)
    habitat = rand(habspec)
    movement = MovementModel(habitat, spec)
    init_pop = eqdist(movement, SIM_K)

    SpatQSimPrep(spec, habitat, movement, init_pop)
end

# File operations ---------------------------------------------------------------
function save(prep::SpatQSimPrep)
    save(prep.habitat, prep.spec)
    save(prep.movement, prep.spec)

    pfn = prep_file(prep.spec)
    h5open(pfn, "cw") do h5
        write_dataset(h5, "init_pop", prep.init_pop.P)
    end
    pfn
end

function load_prep(spec::SpatQSimSpec)
    habitat = load_habitat(spec)
    movement = load_movement(spec)

    pfn = prep_file(spec)
    init_pop = h5open(pfn, "r") do h5
        PopState(read_dataset(h5, "init_pop"))
    end

    SpatQSimPrep(spec, habitat, movement, init_pop)
end

# Prepare multiple realizations -------------------------------------------------
function prep_sims(simtype::Type{<:SpatQSimSpec}, n; base_dir = ".")
    for rlz in 1:n
        spec = simtype(rlz, one(), )
        prep = SpatQSimPrep()
