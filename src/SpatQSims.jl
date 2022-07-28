module SpatQSims

using FisherySim
using Distributions
using NeutralLandscapes
using Plots
using Random
using HDF5
using CSV
using StructArrays
using Arrow

import Base: length, getindex, rand
import FisherySim: simulate, domain, HabitatPreference, MovementModel, Fleet
import Plots: plot

include("scale_devs.jl")
export
    scale_devs,
    scale_log_devs

include("spec.jl")
export
    SpatQSimSpec,
    realization,
    sim_value,
    prep_file,
    domain,
    pop_dynamics,
    n_years,
    QDevScalingSpec,
    SharedQSpec,
    PrefIntensitySpec,
    DensityDependentQSpec,
    HabQSpec,
    BycatchSpec,
    MoveRateSpec

include("files.jl")
export
    file_paths,
    simstudy_dir,
    simstudy_prefix,
    prep_path,
    make_repl_dir

# Control has to be after spec
include("control.jl")
export
    sim_values,
    sim_value_idx

include("habitat.jl")
export
    HabitatSpec,
    length,
    getindex,
    habnames,
    habtypes,
    rand,
    save,
    load_habitat

include("movement.jl")
export
    HabitatPreference,
    MovementModel,
    save,
    load_movement,
    init_pop,
    save,
    load_init_pop

include("prep.jl")
export
    SpatQSimPrep,
    simspec,
    habitat,
    movement,
    init_pop,
    save,
    load_prep,
    prep_sims,
    remove_prep

include("fleet.jl")
export
    survey_catchability,
    comm_catchability,
    survey_targeting,
    comm_targeting,
    tweedie_shape,
    tweedie_dispersion,
    survey_vessel,
    comm_vessel,
    Fleet

include("setup.jl")
export
    SpatQSimSetup,
    simspec,
    init_pop,
    fleet,
    movement,
    pop_dynamics,
    domain,
    n_years

include("simulate.jl")
export
    simulate,
    result_saved,
    run_sims

include("result.jl")
export
    SpatQSimResult,
    simspec,
    file_paths,
    save,
    save_pop_hdf5,
    save_pop_csv,
    save_catch_csv

include("plots.jl")
export
    catch_by_year,
    plot_gif,
    plot

end # module
