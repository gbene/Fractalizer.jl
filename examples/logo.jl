using Fractalizer
using GLMakie


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

fig = Figure()
ax = Axis(fig[1,1], aspect=DataAspect())
lines!(ax, shape.xs, shape.ys)
lines!(ax, fractal.xs, fractal.ys)
display(fig)
