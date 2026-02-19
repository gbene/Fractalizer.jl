using GLMakie
using Fractalizer



noise_params = NoiseParams(0.1:0.1, 1.0:1:10.0, -10.0:1:10.0, 100, 4, 10)
shape_points = [[0., 0.] [1.0,1.0] [3.2, 1.0] [4.2, -0.5] [4.5, -0.9] [7.4, -1.2] [8,-0.7] [8.8,0.0] [9.0, 0.5] [9.6, 0.3]]'

shape1 = Shape(shape_points)
shape2 = ClosedShape(circle(0.,0.,sqrt(1),5))


fig = Figure(size = (800, 800))
ax = Axis(fig[1,1], aspect=DataAspect())
ax2 = Axis(fig[1,2], aspect=DataAspect())
ax3 = Axis(fig[2,1], aspect=DataAspect())
ax4 = Axis(fig[2,2], aspect=DataAspect())

lines!(ax, shape1.points)
lines!(ax2, shape2.points)
lines!(ax3, shape1.points)
lines!(ax4, shape2.points)


fractal1 = fractalize(shape1, noise_params)
fractal2 = fractalize(shape2, noise_params)

fractal3 = fractalize(shape1, 4, noise_params)
fractal4 = fractalize(shape2, 4, noise_params)

lines!(ax, fractal1.points)
lines!(ax2, fractal2.points)
lines!(ax3, fractal3.points)
lines!(ax4, fractal4.points)

display(fig)
