using GLMakie
using Fractalizer



noise_params = NoiseParams(0.1:0.1, 1.0:1:10.0, -10.0:1:10.0, 100, 4, 10)
shape_points = [[0., 2.] [0., 0.]]

shape1 = Shape(shape_points)
shape2 = MakeRing(0.,0.,sqrt(1),5)

fig = Figure(size = (800, 800))
ax = Axis(fig[1,1], aspect=DataAspect())
ax2 = Axis(fig[1,2], aspect=DataAspect())
ax3 = Axis(fig[2,1], aspect=DataAspect())
ax4 = Axis(fig[2,2], aspect=DataAspect())

lines!(ax,  shape1.xs, shape1.ys)
lines!(ax2, shape1.xs, shape1.ys)
lines!(ax3, shape2.xs, shape2.ys)
lines!(ax4, shape2.xs, shape2.ys)


fractal1, templates1 = fractalize(shape1, noise_params)

fractal2 = fractalize(shape1, templates1, 4)

fractal3, templates3 = fractalize(shape2, noise_params)
fractal4 = fractalize(shape2, templates3, 4)

lines!(ax, fractal1.points)
lines!(ax2, fractal2.points)
lines!(ax3, fractal3.points)
lines!(ax4, fractal4.points)

display(fig)
