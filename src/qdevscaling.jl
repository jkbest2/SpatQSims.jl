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

qdev_scales() = 10.0 .^ (-5:-1)
comm_qdev_scale(spec::QDevScalingSpec) = spec.qdev_scale

function qdev_scale_idx(spec::QDevScalingSpec)
    findfirst(isapprox(spec.qdev_scale),
              qdev_scales())
end

function run_qdevscaling_sim(n_repl::Int = 100, prep_file = "prep.h5")
    qdev_scale_vec = qdev_scales()
    for rlz in 1:n_repl
        for sc in qdev_scale_vec
            spec = QDevScalingSpec(rlz, sc, prep_file)
            setup = SpatQSimSetup(spec)
            result = simulate(setup)
            save(result)
        end
    end
    nothing
end
