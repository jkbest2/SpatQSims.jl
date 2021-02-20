"""
    run_sims(simtype::Type{<:SpatQSimSpec},
             repl_range::AbstractRange{<:Integer};
             prep_file = "prep.h5",
             checkpoint = true)

Run simulations of a fishery for replicates in `repl_range`, using `simtype`
spec. If `checkpoint` is `true` any replicates where the simulation result files
are already present will be skipped.
"""
function run_sims(simtype::Type{<:SpatQSimSpec},
                  repl_range::AbstractRange{<:Integer};
                  prep_file = "prep.h5",
                  checkpoint = true)
    study_range = sim_values(simtype)
    for rlz in repl_range
        for val in study_range
            spec = simtype(rlz, val, prep_file)
            files = file_paths(spec)

            # If checkpointing, skip the rest of the inner for loop body if the
            # results files are present.
            if (checkpoint && all(isfile.(files)))
                continue
            end

            setup = SpatQSimSetup(spec)
            result = simulate(setup)
            save(result)
        end
    end
    nothing
end

function run_sims(simtype::Type{<:SpatQSimSpec},
                  n_repl::Integer;
                  prep_file = "prep.h5",
                  checkpoint = true)
    run_sims(simtype, 1:n_repl; prep_file = prep_file, checkpoint = checkpoint)
end
