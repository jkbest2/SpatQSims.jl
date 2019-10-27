function scale_deviation(x, location = one(x), scale = 2one(x))
    x - (x - location) / scale
end

