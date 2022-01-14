"""
A struct to contain all elements required to simulate a fishery.
"""
struct SpatQSimSetup{P,F,M,R,D,S}
    init_pop::P
    fleet::F
    movement::M
    pop_dynamics::R
    domain::D
    n_years::Int
    spec::S

    function SpatQSimSetup(init_pop::P,
                           fleet::F,
                           movement::M,
                           pop_dynamics::R,
                           domain::D,
                           n_years::Int,
                           spec::S) where {
                               P<:PopState,
                               F<:Fleet,
                               M<:MovementModel,
                               R<:PopulationDynamicsModel,
                               D<:AbstractFisheryDomain,
                               S<:SpatQSimSpec}
        new{P,F,M,R,D,S}(init_pop, fleet, movement, pop_dynamics, domain, n_years, spec)
    end
end

function SpatQSimSetup(spec::SpatQSimSpec,
                       prep::SpatQSimPrep)
    SpatQSimSetup(init_pop(prep),
                  fleet(spec, prep),
                  movement(prep),
                  pop_dynamics(spec),
                  domain(spec),
                  n_years(spec),
                  spec)
end

function SpatQSimSetup(spec::SpatQSimSpec)
    prep = SpatQSimPrep(spec)
    SpatQSimSetup(spec, prep)
end

function simulate(setup::SpatQSimSetup)
    P, C = simulate(setup.init_pop,
                    setup.fleet,
                    setup.movement,
                    setup.pop_dynamics,
                    setup.domain,
                    setup.n_years)
    SpatQSimResult(P, C, setup.spec)
end

function SpatQSimSetup(spec::HabQSpec, prep::HabQPrep)
    fleet = Fleet([survey_vessel(spec, prep),
                   comm_vessel(spec, prep)],
                  [length(survey_targeting(spec)), 40_000],
                  [1, 2])


    SpatQSimSetup(init_pop(prep),
                  fleet,
                  movement(prep),
                  pop_dynamics(spec),
                  domain(prep),
                  15,
                  spec)
end

function SpatQSimSetup(spec::BycatchSpec, prep::BycatchPrep)
    fleet = Fleet([survey_vessel(spec, prep),
                   comm_vessel(spec, prep)],
                  [length(survey_targeting(spec)), 40_000],
                  [1, 2])


    SpatQSimSetup(init_pop(prep),
                  fleet,
                  movement(prep),
                  pop_dynamics(spec),
                  domain(prep),
                  15,
                  spec)
end
