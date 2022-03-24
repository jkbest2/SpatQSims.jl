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
    if isfile(prep_path(spec))
        prep = load_prep(spec)
    else
        habspec = HabitatSpec(spec)
        habitat = rand(habspec)
        movement = MovementModel(habitat, spec)
        init_pop = eqdist(movement, SIM_K)

        prep = SpatQSimPrep(spec, habitat, movement, init_pop)
    end
    prep
end

# Accessors ---------------------------------------------------------------------
simspec(prep::SpatQSimPrep) = prep.spec
habitat(prep::SpatQSimPrep) = prep.habitat
movement(prep::SpatQSimPrep) = prep.movement
init_pop(prep::SpatQSimPrep) = prep.init_pop
domain(prep::SpatQSimPrep) = domain(simspec(prep))
pop_dynamics(prep::SpatQSimPrep) = pop_dynamics(simspec(prep))

# File operations ---------------------------------------------------------------
function save(prep::SpatQSimPrep; overwrite = false)
    pfn = prep_file(prep.spec)
    if overwrite
        remove_prep(spec; actually_delete = true)
    end

    make_repl_dir(simspec(prep))

    save(habitat(prep), simspec(prep))
    save(movement(prep), simspec(prep))
    save(init_pop(prep), simspec(prep))

    pfn
end

function save(prep::SpatQSimPrep{<:HabQSpec}; overwrite = false)
    pfn = prep_file(prep.spec)
    if overwrite
        remove_prep(spec; actually_delete = true)
    end

    make_repl_dir(simspec(prep))

    save(habitat(prep), simspec(prep))

    pfn
end


function load_prep(spec::SpatQSimSpec)
    habitat = load_habitat(spec)
    movement = load_movement(spec)
    init_pop = load_init_pop(spec)

    SpatQSimPrep(spec, habitat, movement, init_pop)
end

# Special-case HabQSpec to allow movement to vary among sim values; need to
# recalculate movement operator and initial population each time.
function load_prep(spec::HabQSpec)
    habitat = load_habitat(spec)
    movement = MovementModel(habitat, spec)
    init_pop = eqdist(movement, SIM_K)

    SpatQSimPrep(spec, habitat, movement, init_pop)
end

# Prepare multiple realizations -------------------------------------------------
function prep_sims(simtype::Type{<:SpatQSimSpec}, n; base_dir = ".")
    pfns = String[]
    for rlz in 1:n
        spec = simtype(rlz, sim_values(simtype)[1]; base_dir = base_dir)
        prep = SpatQSimPrep(spec)
        push!(pfns, save(prep))
    end
    pfns
end

# Delete saved prep -------------------------------------------------------------
function remove_prep(spec::SpatQSimSpec; actually_delete = false)
    pfn = prep_path(spec)
    if actually_delete && isfile(pfn)
        rm(pfn)
    end
    pfn
end
