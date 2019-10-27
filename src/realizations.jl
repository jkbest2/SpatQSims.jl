"""
    generate_realizations(n::Int,
                          domdist::DomainDistribution)

Generate `n` realizations from the domain distribution `domdist`, return as a
vector of matrices. Currently restricted to `Float64` elements. Useful for
generating habitats and spatially varying catchabilities that are realization within
replicates.
"""
function generate_realizations(domdist::DomainDistribution, n::Int)
    realizations = Vector{Matrix{Float64}}()
    for rlz in 1:n
        push!(realizations, rand(domdist))
    end
    realizations
end

"""
    save_realizations(fn::AbstractString,
                      habitats::Vector{Matrix{Float64}},
                      name::AbstractString)

Save a vector of `DomainDistribution` realizations as a 3-dimensional array
using the HDF5 package as a data set `name` in the file `fn`.
"""
function save_realizations(fn::AbstractString,
                           name::AbstractString,
                           realizations::Vector{Matrix{Float64}})
    fid = h5open(fn, "cw")
    try
        _dims = size(realizations[1])
        _n = length(realizations)
        dset = d_create(fid, name, datatype(Float64),
                        dataspace(_dims..., _n),
                        "chunk", (_dims..., 1))
        for (idx, rlzn) in enumerate(realizations)
            dset[:, :, idx] = rlzn
        end
        return nothing
    catch
        @error "Problem encountered; realizations probably not saved."
    finally
        close(fid)
    end
end

"""
    load_realization(fn::AbstractString,
                     name::AbstractString,
                     n::Integer)

Load the `n`th realization of the dataset `name` in the HDF5 file `fn`.
"""
function load_realization(fn::AbstractString,
                          name::AbstractString,
                          n::Integer)
    fid = h5open(fn, "r")
    try
        return dropdims(fid[name][:, :, n]; dims = 3)
    catch
        @error "Could not read realization" n
    finally
        close(fid)
    end
end

"""
    save_movements(fn::AbstractString,
                   moves::Vector{M}) where M<:MovementModel

Save vector of `MovementModel` objects as 3-dimensional HDF5 array.
"""
function save_realizations(fn::AbstractString, name::AbstractString,
                           moves::Vector{M}) where M<:MovementModel
    move_ops = getfield.(moves, :M)
    save_realizations(fn, name, move_ops)
end

function load_movement(fn::AbstractString, name::AbstractString, n::Integer)
    MovementModel(load_realization(fn, name, n))
end

function save_realizations(fn::AbstractString, name::AbstractString,
                           popstates::Vector{P}) where P<:PopState
    pops = getfield.(popstates, :P)
    save_realizations(fn, name, pops)
end

function load_popstate(fn::AbstractString, name::AbstractString, n::Integer)
    PopState(load_realization(fn, name, n))
end

function save_realizations(fn::AbstractString, name::AbstractString,
                           spatqs::Vector{C}) where C<:Catchability
    qs = getfield.(spatqs, :catchability)
    save_realizations(fn, name, qs)
end

function load_catchability(fn::AbstractString, name::AbstractString, n::Integer)
    Catchability(load_realization(fn, name, n))
end

