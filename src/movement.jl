# Habitat preference functions --------------------------------------------------
function edge_hab(dom, p = 0.5)
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

function rocky_hab_pref_gen(pref = 1.0)
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


# File operations ---------------------------------------------------------------
function save(moveop::MovementModel, spec::SpatQSimSpec)
    make_repl_dir(spec)
    pfn = prep_file(spec)
    h5open(pfn, "cw") do h5
        write_dataset(h5, "movement", moveop.M)
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
