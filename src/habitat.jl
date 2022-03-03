# Specifying different habitat structures ---------------------------------------
struct HabitatSpec
    habs::Vector{Pair{String, DataType}}
end

function HabitatSpec(simtype::Type{<:SpatQSimSpec})
    HabitatSpec(["habitat" => Float64,
                 "logq" => Float64])
end

function HabitatSpec(simtype::Type{<:DensityDependentQSpec})
    HabitatSpec(["habitat" => Float64])
end

function HabitatSpec(simtype::Type{<:HabQSpec})
    HabitatSpec(["rocky_habitat" => Bool])
end

function HabitatSpec(simtype::Type{<:BycatchSpec})
    HabitatSpec(["habitat" => Float64,
                 "rocky_habitat" => Bool])
end

HabitatSpec(spec::SpatQSimSpec) = HabitatSpec(typeof(spec))

length(habspec::HabitatSpec) = length(habspec.habs)
getindex(habspec::HabitatSpec, idx) = habspec.habs[idx]

habnames(habspec::HabitatSpec) = first.(habspec.habs)
habtypes(habspec::HabitatSpec) = last.(habspec.habs)

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
hab_presave(hab::Matrix) = hab
hab_presave(hab::BitMatrix) = Matrix{Bool}(hab)
function save(hab::Habitat, spec::SpatQSimSpec)
    habspec = HabitatSpec(spec)
    hns = habnames(habspec)

    make_repl_dir(spec)
    h5open(prep_file(spec), "w") do h5
        for idx in 1:length(hab)
            h = hab[idx]
            h2 = hab_presave(h)
            write_dataset(h5, hns[idx], h2)
        end
    end
    prep_file(spec)
end

hab_postload(hab::Matrix) = hab
hab_postload(hab::Matrix{Bool}) = BitMatrix(hab)
function load_habitat(spec::SpatQSimSpec)
    habspec = HabitatSpec(spec)
    hns = habnames(habspec)

    pfn = prep_file(spec)
    habs = Any[]
    h5open(pfn, "r") do h5
        for idx in 1:length(habspec)
            h = read_dataset(h5, hns[idx])
            h2 = hab_postload(h)
            push!(habs, h2)
        end
    end
    Habitat(habs...)
end
