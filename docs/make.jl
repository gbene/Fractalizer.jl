using Documenter, Fractalizer, CairoMakie

pages = ["Home" => "index.md","Examples"=>"examples.md", "Types" => "types.md", "Functions" => "functions.md", "API"=>"api.md"]

if "local" in ARGS
        run(`rm -rf local_build/`)
        makedocs(sitename="Fractalizer.jl", pages=pages, format = Documenter.HTML(
        prettyurls = false), build="local_build", clean=true)
else
        makedocs(sitename="Fractalizer.jl", pages=pages, clean=true)
end

deploydocs(repo="github.com:gbene/Fractalizer.jl.git")