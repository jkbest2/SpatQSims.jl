function edge_hab(dom, p = 0.5)
    lower = ceil(Int, 100 * (1 - p))
    upper = floor(Int, 100 * p)
    hab = zeros(Int, size(dom))
    hab[lower:upper, lower:upper] .= 1
    src = LinearIndices(size(dom))[findall(==(1), hab)]
    dgr = DistanceGradient(src)
    -rand(dgr, 100, 100)
end

function general_hab_distr(dom, mean = zeros(size(dom)))
    cov_kernel = Matérn32Cov(1.0, 20.0)
    cov_mat = cov(cov_kernel, dom)
    DomainDistribution(MvNormal(vec(mean), cov_mat), dom)
end

function general_hab_pref(gh)
    cdf(Normal(), gh)
end

function rocky_hab_distr(dom; wts = [0.75, 0.25])
    cov_kernel = Matérn32Cov(1.0, 5.0)
    cov_mat = cov(cov_kernel, dom)
    distr = MvNormal(cov_mat)
    ClassifiedDomainDistribution(distr, dom, wts)
end

function rocky_hab_pref_gen(pref = 1.0)
    function pref_fn(rh)
        rh ? pref : one(pref)
    end
    pref_fn
end

function generate_habitat(dom)
    gen_hab = rand(general_hab_distr(dom))
    rocky_hab = rand(rocky_hab_distr(dom))
    Habitat(gen_hab, rocky_hab)
end

#-------------------------------------------------------------------------------

function move_rate()
    mov_fn(d) = Matérn32Cov(1.0, 2.5)(d)
    MovementRate(mov_fn)
end

function hab_pref(rocky_pref)
    # HabitatPreference(general_hab_pref, rocky_hab_pref_gen(rocky_pref))
    HabitatPreference(gh -> 1, rocky_hab_pref_gen(rocky_pref))
end

function make_moveop(hab::Habitat, rocky_pref, dom::AbstractFisheryDomain)
    MovementModel(hab, hab_pref(rocky_pref), move_rate(), dom)
end

#-------------------------------------------------------------------------------

struct HabQSpec{T} <: SpatQSimSpec
    realization::Int
    rocky_pref::T
    prep_file::String

    function HabQSpec(realization::Int,
                      rocky_pref::T,
                      prep_file::String) where T<:Real
        new{T}(realization, rocky_pref, prep_file)
    end
end

function HabQSpec(realization::Integer,
                  rocky_pref::T;
                  base_dir = ".") where T<:Real
    prep_fn = prep_path(HabQSpec, realization; base_dir = base_dir)
    HabQSpec(realization, rocky_pref, prep_fn)
end

sim_value(spec::HabQSpec) = spec.rocky_pref

#-------------------------------------------------------------------------------

struct HabQPrep{D, H, M, P}
    domain::D
    habitat::H
    movement::M
    init_pop::P

    function HabQPrep(domain::D, habitat::H, movement::M, init_pop::P) where {D<:AbstractFisheryDomain,
                                                                              H<:Habitat,
                                                                              M<:MovementModel,
                                                                              P<:PopState}
        new{D, H, M, P}(domain, habitat, movement, init_pop)
    end
end

domain(prep::HabQPrep) = prep.domain
habitat(prep::HabQPrep) = prep.habitat
movement(prep::HabQPrep) = prep.movement
init_pop(prep::HabQPrep) = prep.init_pop

function HabQPrep(spec::HabQSpec; K = 100, save = false, base_dir = ".")
    dom = GriddedFisheryDomain()
    hab_fn = prep_file(spec)
    if !isfile(hab_fn)
        hab = prepare_habitat(spec, save = save, base_dir = base_dir)
    else
        hab = get_habitat(spec)
    end
    move = make_moveop(hab, sim_value(spec), dom)
    init_pop = eqdist(move, K)

    HabQPrep(dom, hab, move, init_pop)
end

function prepare_habitat(simtype::Type{<:HabQSpec}, realization::Integer; save = true, base_dir = ".")
    dom = GriddedFisheryDomain()
    hab = generate_habitat(dom)
    if save
        fn = prep_path(simtype, realization)
        h5open(fn, "w") do fid
            dom_size = size(hab)
            ghab = create_dataset(fid, "general_hab", datatype(Float64), dataspace(dom_size...))
            ghab = hab[1]
            rhab = create_dataset(fid, "rocky_hab", datatype(Bool), dataspace(dom_size...))
            rhab = hab[2]
        end
    end
    hab
end
function prepare_habitat(spec::HabQSpec; save = true, base_dir = ".")
    prepare_habitat(typeof(spec), realization(spec); save = save, base_dir = base_dir)
end

function get_habitat(spec::HabQSpec)
    prep_fn = prep_file(spec)
    fid = h5open(prep_fn, "r")
    ghab = read_dataset(fid, "general_hab")
    rhab = read_dataset(fid, "rocky_hab")
    close(fid)
    Habitat(ghab, rhab)
end

#-------------------------------------------------------------------------------

function survey_vessel(spec::HabQSpec, prep::HabQPrep)
    dom = domain(prep)
    hab = habitat(prep)
    q = HabitatCatchability(hab, base_catchability().catchability, gh -> 1.0, rh -> rh ? 0.1 : 1.0)
    q_real = getfield.(getindex.(Ref(q), eachindex(dom)), :catchability)
    survey_q = Catchability(reshape(q_real, size(dom)...))
    Vessel(survey_targeting(spec), survey_q, tweedie_shape(spec), tweedie_dispersion(spec))
end

function comm_vessel(spec::HabQSpec, prep::HabQPrep)
    dom = domain(prep)
    hab = habitat(prep)
    q = HabitatCatchability(hab, base_catchability().catchability, gh -> 1.0, rh -> rh ? 0.9 : 1.0)
    q_real = getfield.(getindex.(Ref(q), eachindex(dom)), :catchability)
    comm_q = Catchability(reshape(q_real, size(dom)...))
    comm_target = DynamicPreferentialTargeting(init_pop(prep).P,
                                               p -> comm_q.catchability .* p)
    Vessel(comm_target, comm_q, tweedie_shape(spec), tweedie_dispersion(spec))
end


#-------------------------------------------------------------------------------

function run_sims(simtype::Type{HabQSpec},
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

function complete_results(spec; csv = false, feather = true)
    files = file_paths(spec)
    complete = isfile(files[1])
    if csv
        complete &= all(isfile.(files[2:3]))
    end
    if feather
        complete &= all(isfile.(files[4:5]))
    end
    complete
end

function run_sims(simtype::Type{HabQSpec},
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

        prep = HabQPrep(spec; K = 100, save = true, base_dir = base_dir)
        setup = SpatQSimSetup(spec, prep)
        result = simulate(setup)
        save(result; csv = csv, feather = feather)
    end
    nothing
end
