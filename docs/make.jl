# Standard stuff
cd(@__DIR__)
CI = get(ENV, "CI", nothing) == "true" || get(ENV, "GITHUB_TOKEN", nothing) !== nothing
using Documenter
using DocumenterTools: Themes
ENV["JULIA_DEBUG"] = "Documenter"
using CairoMakie
# Packages specific to these docs
using Attractors

# %% JuliaDynamics theme
# It includes themeing for the HTML build
# and themeing for the Makie plotting

using DocumenterTools: Themes
for file in ("juliadynamics-lightdefs.scss", "juliadynamics-darkdefs.scss", "juliadynamics-style.scss")
    filepath = joinpath(@__DIR__, file)
    if !isfile(filepath)
        download("https://raw.githubusercontent.com/JuliaDynamics/doctheme/master/$file", joinpath(@__DIR__, file))
    end
end
# create the themes
for w in ("light", "dark")
    header = read(joinpath(@__DIR__, "juliadynamics-style.scss"), String)
    theme = read(joinpath(@__DIR__, "juliadynamics-$(w)defs.scss"), String)
    write(joinpath(@__DIR__, "juliadynamics-$(w).scss"), header*"\n"*theme)
end
# compile the themes
Themes.compile(joinpath(@__DIR__, "juliadynamics-light.scss"), joinpath(@__DIR__, "src/assets/themes/documenter-light.css"))
Themes.compile(joinpath(@__DIR__, "juliadynamics-dark.scss"), joinpath(@__DIR__, "src/assets/themes/documenter-dark.css"))

# %% Build docs
PAGES = [
    "index.md",
    "attractors.md",
    "basins.md",
    "continuation.md",
    "examples.md",
]

include("style.jl")

makedocs(
    modules = [Attractors, Attractors.DelayEmbeddings],
    format = Documenter.HTML(
        prettyurls = CI,
        assets = [
            asset("https://fonts.googleapis.com/css?family=Montserrat|Source+Code+Pro&display=swap", class=:css),
        ],
        collapselevel = 3,
        ),
    sitename = "Attractors.jl",
    authors = "George Datseris, Kalel Rossi, Alexandre Wagemakers",
    pages = PAGES,
    doctest = CI,
    draft = true,
)

if CI
    deploydocs(
        repo = "github.com/JuliaDynamics/Attractors.jl.git",
        target = "build",
        push_preview = true
    )
end
