using GLMakie
using Fractalizer



template_points = [[0., 0.] [1.0,1.0] [3.2, 1.0] [4.2, -0.5] [4.5, -0.9] [7.4, -1.2] [8,-0.7] [8.8,0.0] [9.0, 0.5] [9.6, 0.3]]'

template = Template(template_points)
shape1 = Shape(template_points)

shape2 = ClosedShape(makecircle(0.,0.,sqrt(1),5))

# shape2 = shape2*R(45)

fig = Figure(size = (800, 800))
ax = Axis(fig[1,1], aspect=DataAspect())
ax2 = Axis(fig[1,2], aspect=DataAspect())
ax3 = Axis(fig[2,1], aspect=DataAspect())
ax4 = Axis(fig[2,2], aspect=DataAspect())

lines!(ax, shape1.points)
lines!(ax2, shape2.points)
lines!(ax3, shape1.points)
lines!(ax4, shape2.points)


fractal1 = fractalize(shape1, template)
fractal2 = fractalize(shape2, template)

fractal3 = fractalize(shape1, template, 4)
fractal4 = fractalize(shape2, template, 4)

lines!(ax, fractal1.points)
lines!(ax2, fractal2.points)
lines!(ax3, fractal3.points)
lines!(ax4, fractal4.points)

display(fig)
