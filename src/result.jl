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

simspec(result::SpatQSimResult) = result.spec
realization(result::SpatQSimResult) = realization(simspec(result))

function save(result::SpatQSimResult; csv = false, feather = true)
    make_repl_dir(simspec(result))

    files = file_paths(simspec(result))
    save_pop_hdf5(result, files[:pop_h5])
    if (csv)
        save_pop_csv(result, files[:pop_csv])
        save_catch_csv(result, files[:catch_csv])
    end
    if (feather)
        save_pop_feather(result, files[:pop_feather])
        save_catch_feather(result, files[:catch_feather])
    end
    files
end

function save_pop_hdf5(result::SpatQSimResult, file_name::String)
    domain_size = size(domain(simspec(result)))
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

function save_pop_feather(result::SpatQSimResult, file_name::String)
    popstate = (pop = sum.(result.pop_state), )
    Arrow.write(file_name, StructArray(popstate))
    file_name
end

function save_catch_feather(result::SpatQSimResult, file_name::String)
    Arrow.write(file_name, StructArray(result.catch_record))
    file_name
end
