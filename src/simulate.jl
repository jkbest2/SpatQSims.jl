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
                  checkpoint = true,
                  csv = false,
                  feather = true)
    for spec in specs
        if isfile(prep_path(spec))
            continue
        else
            prep = SpatQSimPrep(spec)
            save(prep)
        end
    end

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
                  checkpoint = true,
                  csv = false,
                  feather = true)
    specs = simtype.(repls, (sim_values(simtype))')
    run_sims(specs;
             checkpoint = checkpoint,
             csv = csv,
             feather = feather)
end
