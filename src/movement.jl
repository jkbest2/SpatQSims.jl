# Habitat preference functions --------------------------------------------------
function edge_hab(dom, p=0.5)
    lower = ceil(Int, 100 * (1 - p))
    upper = floor(Int, 100 * p)
    hab = zeros(Int, size(dom))
    hab[lower:upper, lower:upper] .= 1
    src = LinearIndices(size(dom))[findall(==(1), hab)]
    dgr = DistanceGradient(src)
    -rand(dgr, 100, 100)
end

function continuous_hab_pref(gh)
    cdf(Normal(), gh)
end

function rocky_hab_pref_gen(pref=1.0)
    function pref_fn(rh)
        rh ? pref : one(pref)
    end
    pref_fn
end

# Scenario-specific habitat preferences -----------------------------------------
# QDevScaling, SharedQ, and PrefIntensity
function HabitatPreference(spec::SpatQSimSpec)
    HabitatPreference(continuous_hab_pref, one)
end

# DensityDependentQ
function HabitatPreference(spec::DensityDependentQSpec)
    HabitatPreference(continuous_hab_pref)
end

# HabQ
function HabitatPreference(spec::HabQSpec)
    rocky_pref = spec.rocky_pref
    HabitatPreference(rocky_hab_pref_gen(rocky_pref))
end

# Bycatch
function HabitatPreference(spec::BycatchSpec)
    HabitatPreference(continuous_hab_pref, one)
end

# Movement distance -------------------------------------------------------------
const SIM_MOVERATE = MovementRate(d -> Matérn32Cov(1.0, 2.5)(d))

# Movement operator -------------------------------------------------------------
function MovementModel(hab::Habitat, spec::SpatQSimSpec)
    pref = HabitatPreference(spec)
    dom = domain(spec)
    MovementModel(hab, pref, SIM_MOVERATE, dom)
end

function MovementModel(hab::Habitat, spec::MoveRateSpec)
    pref = HabitatPreference(spec)
    dom = domain(spec)
    moverate = MovementRate(d -> Matérn32Cov(1.0, sim_value(spec))(d))
    MovementModel(hab, pref, moverate, dom)
end

# File operations ---------------------------------------------------------------
function save(moveop::MovementModel, spec::SpatQSimSpec)
    make_repl_dir(spec)
    pfn = prep_file(spec)
    h5open(pfn, "cw") do h5
        if !haskey(h5, "movement")
            write_dataset(h5, "movement", moveop.M)
        else
            @warn "movement already saved in $pfn"
        end
    end
    pfn
end

function save(moveop::MovementModel, spec::Union{HabQSpec,MoveRateSpec})
    make_repl_dir(spec)
    pfn = prep_file(spec)
    h5open(pfn, "cw") do h5
        if !haskey(h5, "movement")
            write_dataset(h5, "movement", fill(NaN, size(moveop.M)))
        else
            @warn "movement already saved in $pfn"
        end
    end
    pfn
end

function load_movement(spec::SpatQSimSpec)
    pfn = prep_file(spec)
    M = h5open(pfn, "r") do h5
        read_dataset(h5, "movement")
    end
    MovementModel(M, size(SIM_DOMAIN))
end

function load_movement(spec::Union{HabQSpec,MoveRateSpec})
    hab = load_habitat(spec)
    MovementModel(hab, spec)
end

# Steady-state population -------------------------------------------------------
function init_pop(mov::MovementModel, K=SIM_K)
    eqdist(mov, K)
end

# Steady-state population save and load -----------------------------------------
function save(init_pop::PopState, spec::SpatQSimSpec)
    make_repl_dir(spec)
    pfn = prep_path(spec)
    h5open(pfn, "cw") do h5
        if !haskey(h5, "init_pop")
            write_dataset(h5, "init_pop", init_pop.P)
        else
            @warn "init_pop already saved in $pfn"
        end
    end
    pfn
end

function save(init_pop::PopState, spec::Union{HabQSpec,MoveRateSpec})
    make_repl_dir(spec)
    pfn = prep_file(spec)
    h5open(pfn, "cw") do h5
        if !haskey(h5, "init_pop")
            write_dataset(h5, "init_pop", fill(NaN, size(SIM_DOMAIN)))
        else
            @warn "init_pop already saved in $pfn"
        end
    end
    pfn
end

function load_init_pop(spec::SpatQSimSpec)
    pfn = prep_file(spec)
    p0 = h5open(pfn, "r") do h5
        read_dataset(h5, "init_pop")
    end
PopState(p0)
end

function load_init_pop(spec::Union{HabQSpec,MoveRateSpec})
    pfn = prep_file(spec)
    moveop = load_movement(spec)
    eqdist(moveop, SIM_K)
end
