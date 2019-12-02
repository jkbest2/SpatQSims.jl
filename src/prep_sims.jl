"""
    prep_sims(n = 100, prep_fn = "prep.h5", K = 100.0)

Prepare `n` replicates of habitat, movement, spatial equilibium, and
catchability deviations.
"""
function prep_sims(n = 100, prep_fn = "prep.h5", K = 100.0)
    # Set seed for reproducibility. Passing RNGs directly doesn't work yet.
    Random.seed!(2020)

    # Use 100×100 gridded fishery domain for all simulations
    Ω = GriddedFisheryDomain()

    #-Habitat-------------------------------------------------------------------
    # Declare habitat distribution
    habitat_kernel = Matérn32Cov(4.0, 30.0)
    hab_mean_fn(loc) = cospi(loc[1] / 50.0) + cospi(loc[2] / 50.0)
    habitat_mean = 2hab_mean_fn.(Ω.locs)
    habitat_cov = cov(habitat_kernel, Ω)
    habitat_distribution = DomainDistribution(MvNormal(vec(habitat_mean),
                                                       habitat_cov), Ω)

    #-Movement------------------------------------------------------------------
    # Declare habitat preference function and plot realized preference
    hab_pref_fn(h) = exp(-(h + 5)^2 / 40)
    # Distance travelled in a single step decays exponentially
    distance_fn(d) = exp(-d / 1)

    #-Vessels-------------------------------------------------------------------
    # Catchability deviations - spatially correlated multiplicative noise
    catchability_devs_kern = Matérn32Cov(0.05, 30.0)
    catchability_devs_cov = cov(catchability_devs_kern, Ω)
    catchability_devs_distr = DomainDistribution(MvLogNormal,
                                                 ones(length(Ω)),
                                                 catchability_devs_cov, Ω)

    h5open(prep_fn, "w") do fid
        hab_dset = d_create(fid, "habitat", datatype(Float64),
                            dataspace(size(Ω)..., n),
                            "chunk", (size(Ω)..., 1))
        mov_dset = d_create(fid, "movement", datatype(Float64),
                            dataspace(length(Ω), length(Ω), n),
                            "chunk", (size(Ω)..., 1))
        speq_dset = d_create(fid, "spatial_eq", datatype(Float64),
                             dataspace(size(Ω)..., n),
                             "chunk", (size(Ω)..., 1))
        qdev_dset = d_create(fid, "catchability_devs", datatype(Float64),
                             dataspace(size(Ω)..., n),
                             "chunk", (size(Ω)..., 1))

        hab = zeros(size(Ω)...)
        mov = zeros(length(Ω), length(Ω))
        speq = zeros(size(Ω)...)
        qdev = zeros(size(Ω)...)

        for rlz in 1:n
            # Generate habitats and save
            hab .= rand(habitat_distribution)
            hab_dset[:, :, rlz] = hab

            # Derive movement operator and save
            mov .= MovementModel(Ω, hab, hab_pref_fn, distance_fn).M
            mov_dset[:, :, rlz] = mov

            # Find spatial equilibium distribution and save
            speq .= approx_eqdist(MovementModel(mov, size(Ω)), K).P
            speq_dset[:, :, rlz] = speq

            # Generate spatially correlated catchability deviations
            qdev .= rand(catchability_devs_distr)
            qdev_dset[:, :, rlz] = qdev
        end
    end

    # Return nothing; everything else accessed via saved HDF5 files
    nothing
end
