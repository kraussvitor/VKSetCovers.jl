using VKSetCovers
using Documenter

DocMeta.setdocmeta!(VKSetCovers, :DocTestSetup, :(using VKSetCovers); recursive=true)

makedocs(;
    modules=[VKSetCovers],
    authors="Vitor Krauss",
    sitename="VKSetCovers.jl",
    format=Documenter.HTML(;
        prettyurls = false,
        canonical="https://kraussvitor.github.io/VKSetCovers.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Instance File Reader" => "InstanceFileReader/index.md"
    ]
)

deploydocs(;
    repo="github.com/kraussvitor/VKSetCovers.jl",
    devbranch="master",
)
