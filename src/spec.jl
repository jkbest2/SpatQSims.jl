abstract type SpatQSimSpec end

# Common accessor functions
realization(spec::SpatQSimSpec) = spec.realization
prep_file(spec::SpatQSimSpec) = spec.prep_file

# Common specifications
domain(::SpatQSimSpec) = SIM_DOMAIN
pop_dynamics(::SpatQSimSpec) = Schaefer(0.0, 100.0)

# Number of years to simulate
n_years(::SpatQSimSpec) = SIM_NYEARS


# Catchability deviation scaling ------------------------------------------------
struct QDevScalingSpec{T} <: SpatQSimSpec
    realization::Int
    qdev_scale::T
    prep_file::String

    function QDevScalingSpec(realization::Int,
                             qdev_scale::T,
                             prep_file::String) where T
        qdev_scale in sim_values(QDevScalingSpec) || error("Invalid qdev_scale value")
        new{T}(realization, qdev_scale, prep_file)
    end
end
function QDevScalingSpec(realization::Integer,
                         rocky_pref::T;
                         base_dir = ".") where T<:Real
    prep_fn = prep_path(QDevScalingSpec, realization; base_dir = base_dir)
    QDevScalingSpec(realization, rocky_pref, prep_fn)
end

sim_value(spec::QDevScalingSpec) = spec.qdev_scale

# Shared catchability deviations ------------------------------------------------
struct SharedQSpec{T} <: SpatQSimSpec
    realization::Int
    share_scale::T
    prep_file::String

    function SharedQSpec(realization::Int,
                         share_scale::T,
                         prep_file::String) where T
        share_scale in sim_values(SharedQSpec) || error("Invalid share_scale value")
        new{T}(realization, share_scale, prep_file)
    end
end
function SharedQSpec(realization::Integer,
                     rocky_pref::T;
                     base_dir = ".") where T<:Real
    prep_fn = prep_path(SharedQSpec, realization; base_dir = base_dir)
    SharedQSpec(realization, rocky_pref, prep_fn)
end

sim_value(spec::SharedQSpec) = spec.share_scale

# Preference intensity ----------------------------------------------------------
struct PrefIntensitySpec{T} <: SpatQSimSpec
    realization::Int
    pref_power::T
    prep_file::String

    function PrefIntensitySpec(realization::Int,
                                pref_power::T,
                                prep_file::String) where T
        pref_power in sim_values(PrefIntensitySpec) || error("Invalid pref_power value")
        new{T}(realization, pref_power, prep_file)
    end
end
function PrefIntensitySpec(realization::Integer,
                  rocky_pref::T;
                  base_dir = ".") where T<:Real
    prep_fn = prep_path(PrefIntensitySpec, realization; base_dir = base_dir)
    PrefIntensitySpec(realization, rocky_pref, prep_fn)
end

sim_value(spec::PrefIntensitySpec) = spec.pref_power

# Density-dependent catchability ------------------------------------------------
struct DensityDependentQSpec{T} <: SpatQSimSpec
    realization::Int
    densdep_mult::T
    prep_file::String

    function DensityDependentQSpec(realization::Int,
                             densdep_mult::T,
                             prep_file::String) where T
        densdep_mult in sim_values(DensityDependentQSpec) || error("Invalid densdep_mult value")
        new{T}(realization, densdep_mult, prep_file)
    end
end
function DensityDependentQSpec(realization::Integer,
                  rocky_pref::T;
                  base_dir = ".") where T<:Real
    prep_fn = prep_path(DensityDependentQSpec, realization; base_dir = base_dir)
    DensityDependentQSpec(realization, rocky_pref, prep_fn)
end

sim_value(spec::DensityDependentQSpec) = spec.densdep_mult

# Habitat-dependent catchability ------------------------------------------------
struct HabQSpec{T} <: SpatQSimSpec
    realization::Int
    rocky_pref::T
    prep_file::String

    function HabQSpec(realization::Int,
                      rocky_pref::T,
                      prep_file::String) where T<:Real
        rocky_pref in sim_values(HabQSpec) || error("Invalid rocky_pref value")
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

# Bycatch avoidance -------------------------------------------------------------
struct BycatchSpec{T} <: SpatQSimSpec
    realization::Int
    rocky_q::T
    prep_file::String

    function BycatchSpec(realization::Int,
                         rocky_q::T,
                         prep_file::String) where T<:Real
        rocky_q in sim_values(BycatchSpec) || error("Invalid rocky_q value")
        new{T}(realization, rocky_q, prep_file)
    end
end
function BycatchSpec(realization::Integer,
                     rocky_q::T;
                     base_dir = ".") where T<:Real
    prep_fn = prep_path(BycatchSpec, realization; base_dir = base_dir)
    BycatchSpec(realization, rocky_q, prep_fn)
end

sim_value(spec::BycatchSpec) = spec.rocky_q

# Vary movement rate avoidance -------------------------------------------------------------
struct MoveRateSpec{T} <: SpatQSimSpec
    realization::Int
    move_dist::T
    prep_file::String

    function MoveRateSpec(realization::Int,
                          move_dist::T,
                          prep_file::String) where T<:Real
        move_dist in sim_values(MoveRateSpec) || error("Invalid move_dist value")
        new{T}(realization, move_dist, prep_file)
    end
end
function MoveRateSpec(realization::Integer,
                      move_dist::T;
                      base_dir = ".") where T<:Real
    prep_fn = prep_path(MoveRateSpec, realization; base_dir = base_dir)
    MoveRateSpec(realization, move_dist, prep_fn)
end

sim_value(spec::MoveRateSpec) = spec.move_dist
