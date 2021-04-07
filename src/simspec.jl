abstract type SpatQSimSpec end

# Common accessor functions
realization(spec::SpatQSimSpec) = spec.realization
prep_file(spec::SpatQSimSpec) = spec.prep_file

# Common specifications
domain(::SpatQSimSpec) = GriddedFisheryDomain()
pop_dynamics(::SpatQSimSpec) = Schaefer(0.06, 100.0)

# Default vessel targeting behavior
function survey_targeting(spec::SpatQSimSpec,
                          domain::AbstractFisheryDomain = domain(spec))
    survey_stations = vec(LinearIndices(domain.n)[2:4:98, 5:10:95])
    FixedTargeting(survey_stations)
end
function comm_targeting(spec::SpatQSimSpec, prep::SpatQSimPrep)
    comm_q = comm_catchability(spec, prep)
    DynamicPreferentialTargeting(init_pop(prep).P,
                                 pop -> pop .* comm_q.catchability)
end

# Default catchabilities
base_catchability() = Catchability(0.2)
survey_catchability(::SpatQSimSpec) = base_catchability()
comm_qdev_scale(::SpatQSimSpec) = 0.05
function comm_catchability(spec::SpatQSimSpec, prep::SpatQSimPrep)
    qdevs = transform_log_qdevs(log_qdevs(prep), comm_qdev_scale(spec))
    Catchability(base_catchability().catchability .* qdevs)
end

# Define default Tweedie shape and dispersion parameter values
tweedie_shape(::SpatQSimSpec) = 1.84
tweedie_dispersion(::SpatQSimSpec) = 1.2

# Number of years to simulate
n_years(::SpatQSimSpec) = 25

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
function fleet(spec::SpatQSimSpec, prep::SpatQSimPrep)
    survey = survey_vessel(spec)
    n_survey_locs = length(survey.target.locations)
    comm = comm_vessel(spec, prep)
    Fleet([survey, comm],
          [n_survey_locs, 2_500],
          [1, 2])               # survey fishes first
end

function SpatQSimPrep(spec::SpatQSimSpec)
    SpatQSimPrep(realization(spec),
                 prep_file(spec))
end
