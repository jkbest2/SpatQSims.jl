function scale_devs(x, location = one(x), scale = 2one(x))
    x - (x - location) / scale
end

# Rescale the log catchability deviates, debias so that the exponentiated
# process has mean one, and exponentiate to get a multiplicative effect
"""
    scale_log_devs(log_devs, qdev_scale)

Given a vector of (potentially) normally distributed random variates, rescale
its standard deviation by a factor of `qdev_scale` and then exponentiate to
produce log-normally distributed random variates. Includes a bias correction so
that the mean of the resulting vector will have mean `exp(mean(log_devs))`.

    exp(qdev_scale * log_devs .- qdev_scale ^ 2 / 2)
"""
function scale_log_devs(log_devs, dev_scale)
    exp.(dev_scale * log_devs .- dev_scale ^ 2 / 2)
end
