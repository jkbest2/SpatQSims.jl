struct QDevScalingSpec{T} <: SpatQSimSpec
    realization::Int
    qdev_scale::T
    prep_file::String

    function QDevScalingSpec(realization::Int,
                             qdev_scale::T,
                             prep_file::String = "prep.h5") where T
        new{T}(realization, qdev_scale, prep_file)
    end
end

sim_value(spec::QDevScalingSpec) = spec.qdev_scale

comm_qdev_scale(spec::QDevScalingSpec) = sim_value(spec)

