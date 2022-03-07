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
        new{S,P,F,M,R,D}(spec, init_pop, fleet, movement, pop_dynamics, domain, n_years)
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

function SpatQSimSetup(spec::SpatQSimSpec; load_saved = false)
    if load_saved
        prep = load_prep(spec)
    else
        prep = SpatQSimPrep(spec)
    end
    
    SpatQSimSetup(prep)
end

# Accessors ---------------------------------------------------------------------
simspec(setup::SpatQSimSetup) = setup.spec
init_pop(setup::SpatQSimSetup) = setup.init_pop
fleet(setup::SpatQSimSetup) = setup.fleet
movement(setup::SpatQSimSetup) = setup.movement
pop_dynamics(setup::SpatQSimSetup) = setup.pop_dynamics
domain(setup::SpatQSimSetup) = setup.domain
n_years(setup::SpatQSimSetup) = setup.n_years
