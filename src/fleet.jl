# Catchability ------------------------------------------------------------------
# Default
base_catchability() = Catchability(0.01)
comm_qdev_scale(::SpatQSimSpec) = 0.05
comm_qdev_scale(spec::QDevScalingSpec) = sim_value(spec)
function survey_catchability(::SpatQSimSpec)
    base_catchability()
end
function comm_catchability(spec::SpatQSimSpec, prep::SpatQSimPrep)
    qdevs = scale_log_devs(log_qdevs(prep), comm_qdev_scale(spec))
    Catchability(base_catchability().catchability .* qdevs)
end

# Shared catchability
function survey_catchability(spec::SharedQSpec, prep::SpatQSimPrep)
    qdevs = scale_log_devs(log_qdevs(prep),
                           sim_value(spec) * comm_qdev_scale(spec))
    Catchability(base_catchability().catchability .* qdevs)
end

# Density dependent catchability
function comm_catchability(spec::DensityDependentQSpec, prep::SpatQSimPrep)
    DensityDependentCatchability(base_catchability(), spec.densdep_mult)
end

# Habitat-dependent catchability
function survey_catchability(spec::HabQSpec, prep::SpatQSimPrep)
    dom = domain(prep)
    hab = habitat(prep)
    q = HabitatCatchability(hab,
                            base_catchability().catchability,
                            rh -> rh ? 0.1 : 1.0)
    q_real = getfield.(getindex.(Ref(q), eachindex(dom)), :catchability)
    Catchability(reshape(q_real, size(dom)...))
end
function comm_catchability(spec::HabQSpec, prep::SpatQSimPrep)
    dom = domain(prep)
    hab = habitat(prep)
    q = HabitatCatchability(hab,
                            base_catchability().catchability,
                            rh -> rh ? 0.9 : 1.0)
    q_real = getfield.(getindex.(Ref(q), eachindex(dom)), :catchability)
    Catchability(reshape(q_real, size(dom)...))
end

# Bycatch
function comm_catchability(spec::BycatchSpec, prep::SpatQSimPrep)
    dom = domain(prep)
    hab = habitat(prep)
    q = HabitatCatchability(hab,
                            base_catchability().catchability,
                            gh -> 1.0,
                            rh -> rh ? spec.rocky_q : 1.0)
    q_real = getfield.(getindex.(Ref(q), eachindex(dom)), :catchability)
    Catchability(reshape(q_real, size(dom)...))
end

# Targeting ---------------------------------------------------------------------
# Default vessel targeting behavior
function survey_targeting(spec::SpatQSimSpec,
                          domain::AbstractFisheryDomain = domain(spec))
    survey_stations = vec(LinearIndices(domain.n)[3:5:98, 3:5:98])
    StratifiedRandomTargeting((20, 20), domain)
end
function comm_targeting(spec::SpatQSimSpec, prep::SpatQSimPrep)
    comm_q = comm_catchability(spec, prep)
    DynamicPreferentialTargeting(init_pop(prep).P,
                                 pop -> pop .* comm_q.catchability)
end

# Preference intensity
function comm_targeting(spec::PrefIntensitySpec, prep::SpatQSimPrep)
    comm_q = comm_catchability(spec, prep)
    DynamicPreferentialTargeting(init_pop(prep).P,
                                 p -> (comm_q.catchability .* p) .^ sim_value(spec))
end

# Tweedie parameters ------------------------------------------------------------
# Define default Tweedie shape and dispersion parameter values
tweedie_shape(::SpatQSimSpec) = 1.84
tweedie_dispersion(::SpatQSimSpec) = 1.2

# Vessels -----------------------------------------------------------------------
# Define functions to construct survey and commercial vessel types, then use
# these to construct the Fleet
function survey_vessel(spec::SpatQSimSpec)
    Vessel(survey_targeting(spec),
           survey_catchability(spec),
           tweedie_shape(spec),
           tweedie_dispersion(spec))
end
function comm_vessel(spec::SpatQSimSpec, prep::SpatQSimPrep)
    Vessel(comm_targeting(spec, prep),
           comm_catchability(spec, prep),
           tweedie_shape(spec),
           tweedie_dispersion(spec))
end

# Fleet -------------------------------------------------------------------------
function fleet(spec::SpatQSimSpec, prep::SpatQSimPrep)
    survey = survey_vessel(spec)
    n_survey_locs = length(survey.target)
    comm = comm_vessel(spec, prep)
    Fleet([survey, comm],
          [n_survey_locs, SIM_NCOMMFISH],
          [1, 2])               # survey fishes first
end
