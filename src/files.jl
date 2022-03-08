"""
    file_paths(spec::SpatQSimSpec)

Returns paths for population state HDF5 array, population total CSV, and catch
CSV. Will create directories as needed. For example, for the 5th realization
using the second preference intensity value, this function will return a Dict
with the Pairs:

    :pop_h5 => repl_05/prefintensity_02_popstate.h5
    :pop_csv => repl_05/prefintensity_02_popstate.csv
    :catch_csv => repl_05/prefintensity_02_catch.csv
    :pop_feather => repl_05/prefintensity_02_popstate.feather
    :catch_feather => repl_05/prefintensity_02_catch.feather
"""
function file_paths(spec::SpatQSimSpec; base_dir = ".")
    rlz = realization(spec)

    base_dir = normpath(base_dir,
                        simstudy_dir(spec),
                         "repl_" * string(rlz, pad = 2))
    if !isdir(base_dir)
        mkpath(base_dir)
    end

    svi = sim_value_idx(spec)
    isnothing(svi) && error("Invalid sim value")

    file_base = joinpath(base_dir,
                         simstudy_prefix(spec) *
                         string(svi, pad = 2))
    files = file_base .* ["_popstate.h5",
                          "_popstate.csv",
                          "_catch.csv",
                          "_popstate.feather",
                          "_catch.feather",
                          "_prep.h5"]
    Dict(:pop_h5 => files[1],
         :pop_csv => files[2],
         :catch_csv => files[3],
         :pop_feather => files[4],
         :catch_feather => files[5],
         :prep => files[6])
end

"""
Return the directory used to store simulations for the simulation study.
"""
simstudy_dir(::T) where T<:SpatQSimSpec = simstudy_dir(T)
simstudy_dir(::Type{<:QDevScalingSpec}) = "qdevscaling"
simstudy_dir(::Type{<:SharedQSpec}) = "sharedq"
simstudy_dir(::Type{<:PrefIntensitySpec}) = "prefintensity"
simstudy_dir(::Type{<:DensityDependentQSpec}) = "densdepq"
simstudy_dir(::Type{<:HabQSpec}) = "habq"
simstudy_dir(::Type{<:BycatchSpec}) = "bycatch"

"""
Return the file prefix for the simulation study.
"""
simstudy_prefix(::T) where T<:SpatQSimSpec = simstudy_prefix(T)
simstudy_prefix(::Type{<:QDevScalingSpec}) = "qdevscale_"
simstudy_prefix(::Type{<:SharedQSpec}) = "sharedq_"
simstudy_prefix(::Type{<:PrefIntensitySpec}) = "prefintensity_"
simstudy_prefix(::Type{<:DensityDependentQSpec}) = "densdepq_"
simstudy_prefix(::Type{<:HabQSpec}) = "habq_"
simstudy_prefix(::Type{<:BycatchSpec}) = "bycatch_"

function prep_path(simtype::Type{<:SpatQSimSpec}, repl::Integer; base_dir = ".")
    normpath(base_dir,
             simstudy_dir(simtype),
             "repl_" * string(repl, pad = 2),
             simstudy_prefix(simtype) * "prep.h5")
end

function prep_path(spec::SpatQSimSpec; base_dir = ".")
    prep_path(typeof(spec), realization(spec); base_dir = base_dir)
end

function make_repl_dir(simtype::Type{<:SpatQSimSpec}, repl::Integer; base_dir = ".")
    pp = normpath(base_dir,
                  simstudy_dir(simtype),
                  "repl_" * string(repl, pad = 2))
    mkpath(pp)
end
function make_repl_dir(spec::SpatQSimSpec; base_dir = ".")
    make_repl_dir(typeof(spec), realization(spec); base_dir = base_dir)
end
