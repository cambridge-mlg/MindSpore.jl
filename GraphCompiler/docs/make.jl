using GraphCompiler
using Documenter

DocMeta.setdocmeta!(GraphCompiler, :DocTestSetup, :(using GraphCompiler); recursive=true)

makedocs(;
    modules=[GraphCompiler],
    authors="Ross Viljoen <ross@viljoen.co.uk> and contributors",
    repo="https://github.com/rossviljoen/GraphCompiler.jl/blob/{commit}{path}#{line}",
    sitename="GraphCompiler.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://rossviljoen.github.io/GraphCompiler.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/rossviljoen/GraphCompiler.jl",
    devbranch="master",
)
