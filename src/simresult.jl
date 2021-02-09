"""
A struct containing the results of a simulation, including the specification used.
"""
struct SpatQSimResult{P,C,S}
    pop_state::Vector{P}
    catch_record::Vector{C}
    spec::S

    function SpatQSimResult(pop_state::Vector{P},
                            catch_record::Vector{C},
                            spec::S) where {P<:PopState,C<:Catch,S<:SpatQSimSpec}
        new{P,C,S}(pop_state, catch_record, spec)
    end
end

realization(result::SpatQSimResult) = realization(result.spec)
function simstudy_dir(spec::QDevScalingSpec; base_dir = ".")
    joinpath(base_dir, "qdevscaling")
end


"""
    file_paths(spec::QDevScalingSpec)

Returns paths for population state HDF5 array, population total CSV, and catch
CSV. Will create directories as needed. For example, for the 5th realization
using the second catchability deviation scaling factor, this function will
return:

    repl_05/qdevscale_2_popstate.h5
    repl_05/qdevscale_2_popstate.csv
    repl_05/qdevscale_2_catch.csv
"""
function file_paths(spec::QDevScalingSpec; base_dir = ".")
    rlz = realization(spec)

    base_dir = joinpath(simstudy_dir(spec; base_dir = base_dir),
                         "repl_" * string(rlz, pad = 2))
    if !isdir(base_dir)
        mkpath(base_dir)
    end

    file_base = joinpath(base_dir,
                         "qdevscale_" * string(qdev_scale_idx(spec), pad = 2))
    file_base .* ["_popstate.h5",
                  "_popstate.csv",
                  "_catch.csv"]
end

function save(result::SpatQSimResult)
    files = file_paths(result.spec)
    save_pop_hdf5(result, files[1])
    save_pop_csv(result, files[2])
    save_catch_csv(result, files[3])
    files
end

function save_pop_hdf5(result::SpatQSimResult, file_name::String)
    domain_size = size(domain(result.spec))
    h5open(file_name, "w") do fid
        pop_save = create_dataset(fid, "popstate", datatype(Float64),
                                  dataspace(domain_size...,
                                            length(result.pop_state)))
        for yr in eachindex(result.pop_state)
            pop_save[:, :, yr] = result.pop_state[yr].P
        end
    end
    file_name
end

function save_pop_csv(result::SpatQSimResult, file_name::String)
    popstate = (pop = sum.(result.pop_state), )
    CSV.write(file_name, StructArray(popstate))
    file_name
end

function save_catch_csv(result::SpatQSimResult, file_name::String)
    CSV.write(file_name, StructArray(result.catch_record))
    file_name
end
