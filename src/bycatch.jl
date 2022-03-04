
function hab_pref(spec::BycatchSpec)
    HabitatPreference(general_hab_pref, rh -> 1.0)
end

#-------------------------------------------------------------------------------

struct BycatchPrep{D, H, M, P}
    domain::D
    habitat::H
    movement::M
    init_pop::P

    function BycatchPrep(domain::D, habitat::H, movement::M, init_pop::P) where {D<:AbstractFisheryDomain,
                                                                              H<:Habitat,
                                                                              M<:MovementModel,
                                                                              P<:PopState}
        new{D, H, M, P}(domain, habitat, movement, init_pop)
    end
end

domain(prep::BycatchPrep) = prep.domain
habitat(prep::BycatchPrep) = prep.habitat
movement(prep::BycatchPrep) = prep.movement
init_pop(prep::BycatchPrep) = prep.init_pop

function BycatchPrep(spec::BycatchSpec; K = 100, save = false, base_dir = ".")
    dom = GriddedFisheryDomain()
    hab_fn = prep_file(spec)
    if !isfile(hab_fn)
        hab = prepare_habitat(spec, save = save, base_dir = base_dir)
    else
        hab = get_habitat(spec)
    end
    move = make_moveop(hab, spec, dom)
    init_pop = eqdist(move, K)

    BycatchPrep(dom, hab, move, init_pop)
end

function prepare_habitat(simtype::Type{<:BycatchSpec}, realization::Integer; save = true, base_dir = ".")
    dom = GriddedFisheryDomain()
    hab = generate_habitat(dom)
    if save
        fn = prep_path(simtype, realization)
        h5open(fn, "w") do fid
            dom_size = size(hab)
            ghab = create_dataset(fid, "general_hab", datatype(Float64), dataspace(dom_size...))
            ghab[:, :] = hab[1]
            rhab = create_dataset(fid, "rocky_hab", datatype(Bool), dataspace(dom_size...))
            rhab[:, :] = hab[2]
        end
    end
    hab
end
function prepare_habitat(spec::BycatchSpec; save = true, base_dir = ".")
    prepare_habitat(typeof(spec), realization(spec); save = save, base_dir = base_dir)
end

function get_habitat(spec::BycatchSpec)
    prep_fn = prep_file(spec)
    fid = h5open(prep_fn, "r")
    ghab = read_dataset(fid, "general_hab")
    rhab = read_dataset(fid, "rocky_hab")
    close(fid)
    Habitat(ghab, rhab)
end

#-------------------------------------------------------------------------------

function run_sims(simtype::Type{BycatchSpec},
                  repl_range::AbstractRange{<:Integer};
                  base_dir = ".",
                  checkpoint = true,
                  csv = false,
                  feather = true)
    for rlz in repl_range
        run_sims(simtype,
                 rlz;
                 base_dir = base_dir,
                 checkpoint = checkpoint,
                 csv = csv,
                 feather = feather)
    end
    nothing
end

function run_sims(simtype::Type{BycatchSpec},
                  rlz::Integer;
                  base_dir = ".",
                  checkpoint = true,
                  csv = false,
                  feather = true)
    study_range = sim_values(simtype)
    for val in study_range
        spec = simtype(rlz, val, prep_path(simtype, rlz))
        files = file_paths(spec)

        # If checkpointing, skip the rest of the inner for loop body if the
        # results files are present.
        if (checkpoint && complete_results(spec; csv = csv, feather = feather))
            continue
        end

        prep = BycatchPrep(spec; K = 100, save = true, base_dir = base_dir)
        setup = SpatQSimSetup(spec, prep)
        result = simulate(setup)
        save(result; csv = csv, feather = feather)
    end
    nothing
end
