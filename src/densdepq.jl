struct DensityDependentQSpec{T} <: SpatQSimSpec
    realization::Int
    densdep_mult::T
    prep_file::String

    function DensityDependentQSpec(realization::Int,
                             densdep_mult::T,
                             prep_file::String = "prep.h5") where T
        new{T}(realization, densdep_mult, prep_file)
    end
end

sim_value(spec::DensityDependentQSpec) = spec.densdep_mult

function comm_catchability(spec::DensityDependentQSpec)
    DensityDependentCatchability(base_catchability(), spec.densdep_mult)
end
