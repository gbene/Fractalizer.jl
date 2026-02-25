using Fractalizer
using GLMakie


points = [[0., 0.] [2., 0.] [3.0,1.]]'
template1_points = [[0., 1., 2., 3., 4.] [0., 0., 1., 0., 0.]]
template2_points = [[0., 1., 2., 3., 4.] [0., 0., -1., 0., 0.]]

# template_points = [[0., 0.] [1.0,1.0] [3.2, 1.0] [4.2, -0.5] [4.5, -0.9] [7.4, -1.2] [8,-0.7] [8.8,0.0] [9.0, 0.5] [9.6, 0.3]]'


template = Template(template1_points)
template2 = Template(template2_points)

shape1 = Shape(points)


f = fractalize(shape1, [template,template2], 0.0001)


c = f.segment_ids
push!(c, c[end])

fig = Figure()
ax = Axis(fig[1,1], aspect=DataAspect())

# fig, ax, plt = lines(shape1.xs, shape1.ys)
lines!(ax, shape1.xs, shape1.ys)
lines!(ax, f.xs, f.ys; color=c)
xlims!(1.9,2.10)
ylims!(-0.025,0.075)
fig
