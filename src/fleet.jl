# Catchability ------------------------------------------------------------------
# Default
comm_qdev_scale(::SpatQSimSpec) = SIM_COMM_QDEVSCALE
comm_qdev_scale(spec::QDevScalingSpec) = sim_value(spec)

function survey_catchability(::SpatQSimPrep{<:SpatQSimSpec})
    Catchability(SIM_BASEQ)
end
function comm_catchability(prep::SpatQSimPrep{<:SpatQSimSpec})
    spec = simspec(prep)
    habs = habitat(prep)

    qdev_scale = comm_qdev_scale(spec)
    qdevs = scale_log_devs(habs[2], qdev_scale)

    Catchability(SIM_BASEQ .* qdevs)
end

# Shared catchability
function survey_catchability(prep::SpatQSimPrep{<:SharedQSpec})
    spec = simspec(prep)
    habs = habitat(prep)

    qdev_scale = sim_value(spec) * comm_qdev_scale(spec)
    qdevs = scale_log_devs(habs[2], qdev_scale)

    Catchability(SIM_BASEQ .* qdevs)
end

# Density dependent catchability
function comm_catchability(prep::SpatQSimPrep{<:DensityDependentQSpec})
    DensityDependentCatchability(SIM_BASEQ, sim_value(simspec(prep)))
end

# Habitat-dependent catchability
function survey_catchability(prep::SpatQSimPrep{<:HabQSpec})
    dom = domain(prep)
    hab = habitat(prep)

    q = HabitatCatchability(hab,
                            SIM_BASEQ,
                            rh -> rh ? 0.1 : 1.0)
    q_real = getfield.(getindex.(Ref(q), eachindex(dom)), :catchability)
    Catchability(reshape(q_real, size(dom)...))
end
function comm_catchability(prep::SpatQSimPrep{<:HabQSpec})
    dom = domain(prep)
    hab = habitat(prep)

    q = HabitatCatchability(hab,
                            SIM_BASEQ,
                            rh -> rh ? 0.9 : 1.0)
    q_real = getfield.(getindex.(Ref(q), eachindex(dom)), :catchability)
    Catchability(reshape(q_real, size(dom)...))
end

# Bycatch
function comm_catchability(prep::SpatQSimPrep{<:BycatchSpec})
    spec = simspec(prep)
    rocky_q = sim_value(spec)
    dom = domain(prep)
    hab = habitat(prep)

    q = HabitatCatchability(hab,
                            SIM_BASEQ,
                            one,
                            rh -> rh ? rocky_q : 1.0)
    q_real = getfield.(getindex.(Ref(q), eachindex(dom)), :catchability)
    Catchability(reshape(q_real, size(dom)...))
end

# Targeting ---------------------------------------------------------------------
# Default vessel targeting behavior
function survey_targeting(prep::SpatQSimPrep)
    dom = domain(prep)
    StratifiedRandomTargeting((20, 20), dom)
end
function comm_targeting(prep::SpatQSimPrep)
    comm_q = comm_catchability(prep)
    DynamicPreferentialTargeting(init_pop(prep).P,
                                 pop -> pop .* comm_q.catchability)
end

# Preference intensity
function comm_targeting(prep::SpatQSimPrep{<:PrefIntensitySpec})
    spec = simspec(prep)
    comm_q = comm_catchability(prep)
    DynamicPreferentialTargeting(init_pop(prep).P,
                                 p -> (comm_q.catchability .* p) .^ sim_value(spec))
end

# Density-dependent catchability
function comm_targeting(prep::SpatQSimPrep{<:DensityDependentQSpec})
    spec = simspec(prep)
    comm_q = comm_catchability(prep)
    p0 = init_pop(prep).P

    DynamicPreferentialTargeting(p0,
                                 pop -> comm_q .* pop)
end

# Vessels -----------------------------------------------------------------------
# Define functions to construct survey and commercial vessel types, then use
# these to construct the Fleet
function survey_vessel(prep::SpatQSimPrep)
    Vessel(survey_targeting(prep),
           survey_catchability(prep),
           SIM_TWEEDIE_SHAPE,
           SIM_TWEEDIE_DISPERSION)
end
function comm_vessel(prep::SpatQSimPrep)
    Vessel(comm_targeting(prep),
           comm_catchability(prep),
           SIM_TWEEDIE_SHAPE,
           SIM_TWEEDIE_DISPERSION)
end

# Fleet -------------------------------------------------------------------------
function Fleet(prep::SpatQSimPrep)
    survey = survey_vessel(prep)
    n_survey_locs = length(survey.target)
    comm = comm_vessel(prep)
    Fleet([survey, comm],
          [n_survey_locs, SIM_NCOMMFISH],
          [1, 2])                           # Survey fishes first
end
