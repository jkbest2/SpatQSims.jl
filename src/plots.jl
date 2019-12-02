function catch_by_year(Cvec::Vector{<:Catch})
    year_catches = zeros(25)
    year_zeros = zeros(25)
    year_effort = zeros(25)
    for c in Cvec
        year_catches[c.time] += c.catch_biomass
        year_zeros[c.time] += c.catch_biomass == 0
        year_effort[c.time] += c.effort
    end
    year_catches, year_zeros, year_effort
end

function plot_gif(Pvec::Vector{<:PopState}, Cvec::Vector{<:Catch}, file)
    year_catches, _ = catch_by_year(Cvec)
    maxP = maximum(maximum.(getfield.(Pvec, :P)))
    minP = minimum(minimum.(getfield.(Pvec, :P)))
    anim = Animation()
    for yr in 2:25
        plot(heatmap(Pvec[yr].P,
                     color = :viridis, clims = (minP, maxP),
                     aspect_ratio = 1),
             plot(year_catches[1:yr],
                  xlim = (0.5, length(year_catches) + 0.5),
                  ylim = (0.0, 1.05maximum(year_catches))))
        frame(anim)
    end
    gif(anim, file, fps = 5)
end

function plot(Pvec::Vector{<:PopState}, Cvec::Vector{<:Catch})
    stock_status = sum.(Pvec)
    year_catches, _ = catch_by_year(Cvec)
    plot(plot(stock_status, title = "Abundance",
              ylims = (0.0, maximum(stock_status))),
         plot(year_catches, title = "Catch",
              ylims = (0.0, maximum(year_catches))),
         layout = (2, 1), legend = false)
end

function plot(Cvec::Vector{<:Catch})
    year_catches, year_zeros, year_effort = catch_by_year(Cvec)
    plot(plot(year_catches, title = "Catch"),
         plot(year_zeros ./ year_effort, title = "Fraction nonencounters"),
         layout = (2, 1))
end

