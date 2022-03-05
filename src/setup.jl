# Constructors ------------------------------------------------------------------
"""
A struct to contain all elements required to simulate a fishery.
"""
struct SpatQSimSetup{S,P,F,M,R,D,}
    spec::S
    init_pop::P
    fleet::F
    movement::M
    pop_dynamics::R
    domain::D
    n_years::Int

    function SpatQSimSetup(spec::S,
                           init_pop::P,
                           fleet::F,
                           movement::M,
                           pop_dynamics::R,
                           domain::D,
                           n_years::Int) where {
                               S<:SpatQSimSpec,
                               P<:PopState,
                               F<:Fleet,
                               M<:MovementModel,
                               R<:PopulationDynamicsModel,
                               D<:AbstractFisheryDomain}
        new{P,F,M,R,D,S}(spec, init_pop, fleet, movement, pop_dynamics, domain, n_years)
    end
end

function SpatQSimSetup(prep::SpatQSimPrep)
    spec = simspec(prep)
    SpatQSimSetup(spec,
                  init_pop(prep),
                  fleet(prep),
                  movement(prep),
                  pop_dynamics(spec),
                  domain(spec),
                  SIM_NYEARS)
end

function SpatQSimSetup(spec::SpatQSimSpec)
    prep = SpatQSimPrep(spec)
    SpatQSimSetup(prep)
end

# Accessors ---------------------------------------------------------------------
simspec(setup::SpatQSimSetup) = setup.spec
init_pop(setup::SpatQSimSetup) = setup.init_pop
fleet(setup::SpatQSimSetup) = setup.fleet
movement(setup::SpatQSimSetup) = setup.movement
pop_dynamics(setup::SpatQSimSetup) = setup.pop_dynamics
domain(setup::SpatQSimSetup) = setup.domain
n_years(setup::SpatQSimSetup) = set.n_years

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

# function SpatQSimSetup(spec::HabQSpec, prep::HabQPrep)
#     fleet = Fleet([survey_vessel(spec, prep),
#                    comm_vessel(spec, prep)],
#                   [length(survey_targeting(spec)), 40_000],
#                   [1, 2])


#     SpatQSimSetup(init_pop(prep),
#                   fleet,
#                   movement(prep),
#                   pop_dynamics(spec),
#                   domain(prep),
#                   15,
#                   spec)
# end

# function SpatQSimSetup(spec::BycatchSpec, prep::BycatchPrep)
#     fleet = Fleet([survey_vessel(spec, prep),
#                    comm_vessel(spec, prep)],
#                   [length(survey_targeting(spec)), 40_000],
#                   [1, 2])


#     SpatQSimSetup(init_pop(prep),
#                   fleet,
#                   movement(prep),
#                   pop_dynamics(spec),
#                   domain(prep),
#                   15,
#                   spec)
# end
