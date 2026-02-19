using GLMakie
using Fractalizer
using PolygonInbounds

x = -2:0.005:2
y = -2:0.005:2

grid = [vec(x'.* ones(length(y))) vec(y .* ones(length(x))')]

noise_params = NoiseParams(0.1:0.1, 1.0:1:10.0, -10.0:1:10.0, 100, 4, 10)

shape = ClosedShape(circle(0.,0.,sqrt(1),5))
fractal = fractalize(shape, 4, noise_params)

mask = inpoly2(grid, fractal.points, fractal.edges)[:,1]
mask = reshape(mask, length(y), length(x))

fig = Figure(size = (800, 800))
ax = Axis(fig[1,1], aspect=DataAspect())
ax2 = Axis(fig[1,2], aspect=DataAspect())

lines!(ax, shape.points)
lines!(ax, fractal.points)
heatmap!(ax2, x, y, mask')



display(fig)
