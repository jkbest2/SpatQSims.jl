function scale_devs(x, location = one(x), scale = 2one(x))
    x - (x - location) / scale
end

# Rescale the log catchability deviates, debias so that the exponentiated
# process has mean one, and exponentiate to get a multiplicative effect
"""
    transform_log_qdevs(log_qdevs, qdev_scale)

Given a vector of (potentially) normally distributed random variates, rescale
its standard deviation by a factor of `qdev_scale` and then exponentiate to
produce log-normally distributed random variates. Includes a bias correction so
that the mean of the resulting vector will have mean `exp(mean(log_qdevs))`.

    exp(qdev_scale * log_qdevs .- qdev_scale ^ 2 / 2)
"""
function transform_log_qdevs(log_qdevs, qdev_scale)
    exp.(qdev_scale * log_qdevs .- qdev_scale ^ 2 / 2)
end
