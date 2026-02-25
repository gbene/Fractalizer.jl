![icon](assets/banner.svg)


Welcome to the Fractalizer docs! 
Fractalizer is a Julia package to fractalize the edges of any given curve or closed ring using either a template or random noise!

## Installation

Open the REPL and type either 

```using Pkg; Pkg.add(url="Fractalizer")``` 

or 

```] add Fractalizer``` 

## Quick example

Here is a basic example to reproduce the fractal in the logo

```@example 
using CairoMakie #hide
using Fractalizer

template_points = [[0., 0.];;
                   [1.0, 1.0];;
                   [3.2, 1.0];;
                   [4.2, -0.5];;
                   [4.5, -0.9];;
                   [7.4, -1.2];;
                   [8,-0.7];;
                   [8.8,0.0];;
                   [9.0, 0.5];;
                   [9.6, 0.3]]'

template = Template(template_points)
shape = MakeRing(0.,0.,sqrt(1),7)

fractal = fractalize(shape, template, 3)
shape = shape * R(-7)

fig = Figure(size=(800,800))#hide
ax = Axis(fig[1,1], aspect=DataAspect())#hide
lines!(ax, shape.xs, shape.ys)#hide
lines!(ax, fractal.xs, fractal.ys)#hide

save("../src/assets/examples/logo.png", fig); nothing #hide
```
![](assets/examples/logo.png)

Easy as that!!
For more examples and information please consult the [Examples](@ref examples) page.

## Acknowledgements

The algorithm at the base of this code was inspired by the following site: [https://line-fractals.vercel.app/](https://line-fractals.vercel.app/)













