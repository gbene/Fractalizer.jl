using Fractalizer
using GLMakie

# template_points = [[0., 0.] [1.0,1.0] [3.2, 1.0] [4.2, -0.5] [4.5, -0.9] [7.4, -1.2] [8,-0.7] [8.8,0.0] [9.0, 0.5] [9.6, 0.3]]'

points = [[0., 0.] [2., 0.] [3.0,1.]]'

noise_params = NoiseParams(0.1:0.1:0.2, 1.0:1:3, -10.0:1:10.0, 100, 4, 10;seeds=[nothing,5,nothing,nothing])

shape = MakeRing(0,0,1,6)
shape = shape*R(45)
# shape = Shape(points)


f, templates = fractalize(shape, noise_params, 0.1)

c = f.segment_ids
push!(c, c[end])

fig = Figure()

ax = Axis(fig[1,1],aspect=DataAspect())

lines!(ax, shape.xs,shape.ys)
lines!(ax, f.xs, f.ys;color=c)
# xlims!(2.50,2.55)
# ylims!(1.27,1.28)
fig
