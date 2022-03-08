# Add a simulate method to the FisherySim function
function simulate(setup::SpatQSimSetup)
    P, C = simulate(init_pop(setup),
                    fleet(setup),
                    movement(setup),
                    pop_dynamics(setup),
                    domain(setup),
                    n_years(setup))

    SpatQSimResult(P, C, simspec(setup))
end

function result_saved(spec::SpatQSimSpec; csv = false, feather = true)
    files = file_paths(spec)
    # Should always have the complete population map
    if !isfile(files[:pop_h5])
        return false
    end

    if csv && (!isfile(files[:pop_csv]) || !isfile(files[:catch_csv]))
        return false
    end

    if feather && (!isfile(files[:pop_feather]) || !isfile(files[:catch_feather]))
        return false
    end

    true
end

function run_sims(specs::Array{<:SpatQSimSpec};
                  load_saved_prep = true,
                  checkpoint = true,
                  csv = false,
                  feather = true)
    for spec in specs
        files = file_paths(spec)
        # If checkpointing, skip the rest of the inner for loop body if the
        # results files are present.
        if (checkpoint && result_saved(spec; csv = csv, feather = feather))
            continue
        end
        setup = SpatQSimSetup(spec; load_saved_prep = true)
        result = simulate(setup)
        save(result; csv = csv, feather = feather)
    end
    nothing
end

function run_sims(simtype::Type{<:SpatQSimSpec},
                  repls::AbstractArray{<:Integer};
                  load_saved_prep = true,
                  checkpoint = true,
                  csv = false,
                  feather = true)
    specs = simtype.(repls, (sim_values(simtype))')
    run_sims(specs;
             load_saved_prep = load_saved_prep,
             checkpoint = checkpoint,
             csv = csv,
             feather = feather)
end


# """
#     run_sims(simtype::Type{<:SpatQSimSpec},
#              repl_range::AbstractRange{<:Integer};
#              prep_file = "prep.h5",
#              checkpoint = true)

# Run simulations of a fishery for replicates in `repl_range`, using `simtype`
# spec. If `checkpoint` is `true` any replicates where the simulation result files
# are already present will be skipped.
# """
# function run_sims(simtype::Type{<:SpatQSimSpec},
#                   repl_range::AbstractRange{<:Integer};
#                   prep_file = "prep.h5",
#                   checkpoint = true,
#                   csv = false,
#                   feather = true)
#     for rlz in repl_range
#         run_sims(simtype,
#                  rlz;
#                  prep_file = prep_file,
#                  checkpoint = checkpoint,
#                  csv = csv,
#                  feather = feather)
#     end
#     nothing
# end

# function run_sims(simtype::Type{<:SpatQSimSpec},
#                   rlz::Integer;
#                   prep_file = "prep.h5",
#                   checkpoint = true,
#                   csv = false,
#                   feather = true)
#     study_range = sim_values(simtype)
#     for val in study_range
#         spec = simtype(rlz, val, prep_file)
#         files = file_paths(spec)

#         # If checkpointing, skip the rest of the inner for loop body if the
#         # results files are present.
#         if (checkpoint && all(isfile.(files)))
#             continue
#         end

#         setup = SpatQSimSetup(spec)
#         result = simulate(setup)
#         save(result; csv = csv, feather = feather)
#     end
#     nothing
# end
