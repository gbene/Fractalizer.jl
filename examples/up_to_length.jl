using Fractalizer
using GLMakie


template_points = [[0., 0.] [1.0,1.0] [3.2, 1.0] [4.2, -0.5] [4.5, -0.9] [7.4, -1.2] [8,-0.7] [8.8,0.0] [9.0, 0.5] [9.6, 0.3]]'

template = Template(template_points)
shape1 = Shape(template_points)


f = fractalize(shape1, template, 0.00005)

fig, ax, plt = lines(shape1.points)
lines!(ax, f.points)
xlims!(4.8,5.2)
ylims!(-0.80,-0.55)
fig
