function scale_devs(x, location = one(x), scale = 2one(x))
    x - (x - location) / scale
end

