struct PrefIntensitySpec{T} <: SpatQSimSpec
    realization::Int
    pref_power::T
    prep_file::String

    function PrefIntensitySpec(realization::Int,
                                pref_power::T,
                                prep_file::String = "prep.h5") where T
        new{T}(realization, pref_power, prep_file)
    end
end

pref_powers() = [1, 2, 4, 8, 16]
function pref_power_idx(spec::PrefIntensitySpec)
    findfirst(isapprox(spec.pref_power),
              pref_powers())
end

function comm_targeting(spec::PrefIntensitySpec, prep::SpatQSimPrep)
    DynamicPreferentialTargeting(init_pop(prep).P,
                                 p -> p .^ spec.pref_power)
end


function simstudy_dir(spec::PrefIntensitySpec; base_dir = ".")
    joinpath(base_dir, "prefintensity")
end

"""
    file_paths(spec::PrefIntensity)

Returns paths for population state HDF5 array, population total CSV, and catch
CSV. Will create directories as needed. For example, for the 5th realization
using the second catchability deviation scaling factor, this function will
return:

    repl_05/prefintensity_02_popstate.h5
    repl_05/prefintensity_02_popstate.csv
    repl_05/prefintensity_02_catch.csv
"""
function file_paths(spec::PrefIntensitySpec; base_dir = ".")
    rlz = realization(spec)

    base_dir = joinpath(simstudy_dir(spec; base_dir = base_dir),
                         "repl_" * string(rlz, pad = 2))
    if !isdir(base_dir)
        mkpath(base_dir)
    end

    file_base = joinpath(base_dir,
                         "prefintensity_" *
                         string(pref_power_idx(spec), pad = 2))
    file_base .* ["_popstate.h5",
                  "_popstate.csv",
                  "_catch.csv"]
end

"""
    run_prefintensity_sim(n_repl::Int = 100, prep_file = "prep.h5")

Simulate `n_repl` replicates of a fishery with different preference intensity.
Preference is varied by powers of abundance.
"""
function run_prefintensity_sim(n_repl::Int = 100, prep_file = "prep.h5")
    pref_pows = pref_powers()
    for rlz in 1:n_repl
        for sc in pref_pows
            spec = PrefIntensitySpec(rlz, sc, prep_file)
            setup = SpatQSimSetup(spec)
            result = simulate(setup)
            save(result)
        end
    end
    nothing
end
