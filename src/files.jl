"""
    file_paths(spec::SpatQSimSpec)

Returns paths for population state HDF5 array, population total CSV, and catch
CSV. Will create directories as needed. For example, for the 5th realization
using the second preference intensity value, this function will return a vector
with the strings:

    repl_05/prefintensity_02_popstate.h5
    repl_05/prefintensity_02_popstate.csv
    repl_05/prefintensity_02_catch.csv
    repl_05/prefintensity_02_popstate.feather
    repl_05/prefintensity_02_catch.feather
"""
function file_paths(spec::SpatQSimSpec; base_dir = ".")
    rlz = realization(spec)

    base_dir = joinpath(simstudy_dir(spec),
                         "repl_" * string(rlz, pad = 2))
    if !isdir(base_dir)
        mkpath(base_dir)
    end

    file_base = joinpath(base_dir,
                         simstudy_prefix(spec) *
                         string(sim_value_idx(spec), pad = 2))
    file_base .* ["_popstate.h5",
                  "_popstate.csv",
                  "_catch.csv",
                  "_popstate.feather",
                  "_catch.feather"]
end

"""
Return the directory used to store simulations for the simulation study.
"""
simstudy_dir(::T) where T<:SpatQSimSpec = simstudy_dir(T)
simstudy_dir(::Type{<:QDevScalingSpec}) = "qdevscaling"
simstudy_dir(::Type{<:SharedQSpec}) = "sharedq"
simstudy_dir(::Type{<:PrefIntensitySpec}) = "prefintensity"
simstudy_dir(::Type{<:DensityDependentQSpec}) = "densdepq"


"""
Return the file prefix for the simulation study.
"""
simstudy_prefix(::T) where T<:SpatQSimSpec = simstudy_prefix(T)
simstudy_prefix(::Type{<:QDevScalingSpec}) = "qdevscale_"
simstudy_prefix(::Type{<:SharedQSpec}) = "sharedq_"
simstudy_prefix(::Type{<:PrefIntensitySpec}) = "prefintensity_"
simstudy_prefix(::Type{<:DensityDependentQSpec}) = "densdepq_"
