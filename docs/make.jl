using Documenter, Fractalizer

pages = ["Home" => "index.md", "Functions" => "functions.md", "Types" => "types.md"]

makedocs(sitename="Fractalizer.jl", pages=pages, format = Documenter.HTML(
        prettyurls = !("local" in ARGS)))