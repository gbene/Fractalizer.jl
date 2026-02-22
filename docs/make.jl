using Documenter, Fractalizer, CairoMakie

pages = ["Home" => "index.md","Examples"=>"examples.md", "Types" => "types.md", "Functions" => "functions.md", "API"=>"api.md"]

makedocs(sitename="Fractalizer.jl", pages=pages, clean=true)


deploydocs(repo="github.com:gbene/Fractalizer.jl.git",devbranch="dev")