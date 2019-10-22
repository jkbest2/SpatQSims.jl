using Documenter, SpatQSims

makedocs(;
    modules=[SpatQSims],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/jkbest2/SpatQSims.jl/blob/{commit}{path}#L{line}",
    sitename="SpatQSims.jl",
    authors="John K Best",
    assets=String[],
)

deploydocs(;
    repo="github.com/jkbest2/SpatQSims.jl",
)
