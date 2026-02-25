using Fractalizer
using GLMakie



noise_params = NoiseParams(0.1:0.1:0.2, 1.0:1:3, -10.0:1:10.0, 100, 4, 10;seeds=[nothing,5,nothing,nothing])

shape = MakeRing(0,0,1,6)
shape = shape*R(45)

f, templates = fractalize(shape, noise_params, 0.1)


fig = Figure()

ax = Axis(fig[1,1],aspect=DataAspect())

lines!(ax, shape.xs,shape.ys)
lines!(ax, f.xs, f.ys)

display(fig)
