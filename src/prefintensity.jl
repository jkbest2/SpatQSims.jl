struct PrefIntensitySpec{T} <: SpatQSimSpec
    realization::Int
    pref_power::T
    prep_file::String

    function PrefIntensitySpec(realization::Int,
                                pref_power::T,
                                prep_file::String = "prep.h5") where T
        new{T}(realization, pref_power, prep_file)
    end
end

sim_value(spec::PrefIntensitySpec) = spec.pref_power

function comm_targeting(spec::PrefIntensitySpec, prep::SpatQSimPrep)
    DynamicPreferentialTargeting(init_pop(prep).P,
                                 p -> p .^ sim_value(spec))
end
