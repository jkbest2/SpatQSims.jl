# Specifying different habitat structures ---------------------------------------
struct HabitatSpec
    habs::Vector{Pair{String, DataType}}
end

function HabitatSpec(simtype::Type{<:SpatQSimSpec})
    HabSpec(["habitat" => Float64,
             "logq" => Float64])
end

function HabitatSpec(simtype::Type{<:DensityDependentQSpec})
    HabSpec(["habitat" => Float64])
end

function HabitatSpec(simtype::Type{<:HabQSpec})
    HabSpec(["rocky_habitat" => Bool])
end

function HabitatSpec(simtype::Type{<:BycatchSpec})
    HabSpec(["habitat" => Float64,
             "rocky_habitat" => Bool])
end

HabitatSpec(spec::SpatQSimSpec) = HabitatSpec(typeof(spec))

length(habspec::HabitatSpec) = length(HabitatSpec.habs)
getindex(habspec::HabitatSpec, idx) = HabitatSpec.habs[idx]

# Generating habitat realizations -----------------------------------------------

# This distribution is constant for all scenarios, so might as well construct
# this distribution at the beginning and declare it `const`. Using a `let` block
# to scope the intermediate results.
const cont_hab_distr = let
    cov_kernel = Matérn32Cov(1.0, 20.0)
    cov_mat = cov(cov_kernel, SIM_DOMAIN)
    DomainDistribution(MvNormal(cov_mat), SIM_DOMAIN)
end
const bin_hab_distr = let
    cov_kernel = Matérn32Cov(1.0, 5.0)
    cov_mat = cov(cov_kernel, SIM_DOMAIN)
    distr = MvNormal(cov_mat)
    ClassifiedDomainDistribution(distr, SIM_DOMAIN, [0.75, 0.25])
end

function _genhab(habtype::Type{Float64})
    rand(cont_hab_distr)
end

function _genhab(habtype::Type{Bool})
    rand(bin_hab_distr)
end

function rand(habspec::HabitatSpec)
    habs = Any[]
    for (habname, habtype) in habspec.habs
        push!(habs, _genhab(habtype))
    end
    Habitat(habs...)
end

# File operations ---------------------------------------------------------------
function save(hab::Habitat, spec::SpatQSimSpec; base_dir = ".")
    habspec = HabitatSpec(spec)
end

function load_habitat(spec::SpatQSimSpec)
    habspec = HabitatSpec(spec)
end
