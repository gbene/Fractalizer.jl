using Fractalizer
using GLMakie


shape_points = [[0., 2., 3.] [0., 0., 1.0]]
template1_points = [[0., 1., 2., 3., 4.] [0., 0., 1., 0., 0.]]
template2_points = [[0., 1., 2., 3., 4.] [0., 0., -1., 0., 0.]]

template = Template(template1_points)
template2 = Template(template2_points)

shape1 = Shape(shape_points)


f = fractalize(shape1, [template,template2], 0.0001)




fig = Figure()
ax = Axis(fig[1,1], aspect=DataAspect())

lines!(ax, shape1.xs, shape1.ys)
lines!(ax, f.xs, f.ys)

display(fig)
