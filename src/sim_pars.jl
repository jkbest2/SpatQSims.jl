# """
#     sim_values(::Type{T}) where T<:SpatQSimSpec
#     sim_values(::T) where T<:SpatQSimSpec

# Return the values of the parameters that change for each simulation study.
# """
# sim_values(::T) where T<:SpatQSimSpec = sim_values(T)
# sim_values(::Type{<:QDevScalingSpec}) = 10.0 .^ (-3:0.5:-0.5)
# sim_values(::Type{<:SharedQSpec}) = 0:0.2:1
# sim_values(::Type{<:PrefIntensitySpec}) = [0, 1, 2, 4, 8, 16]
# sim_values(::Type{<:DensityDependentQSpec}) = 0:0.25:1.25
# sim_values(::Type{<:HabQSpec}) = 2.0 .^ (-2:3)
# sim_values(::Type{<:BycatchSpec}) = 0.0:0.2:1.0

# function sim_value_idx(spec::SpatQSimSpec)
#     findfirst(isapprox(sim_value(spec)),
#               sim_values(spec))
# end
