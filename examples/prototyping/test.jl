using GLMakie
using LinearAlgebra
using PolygonInbounds





# function make_buffer(shape::T, h) where T<:AbstractShape
#     bpoints = copy(shape.points)
#     for i in 1:shape.nsegments
#         point_idxs = shape.edges[i,:]

#         bpoints[point_idxs, :] .+= h*shape.segment_normals[i,:]'

#     end
#     return T(bpoints)
# end














x = -2:0.005:2
y = -2:0.005:2

grid = [vec(x'.* ones(length(y))) vec(y .* ones(length(x))')]



noise_params = NoiseParams(0.1:0.1, 1.0:1:10.0, -10.0:1:10.0, 100, 4, 10)


template = [[0., 0.] [1.0,1.0] [3.2, 1.0] [4.2, -0.5] [4.5, -0.9] [7.4, -1.2] [8,-0.7] [8.8,0.0] [9.0, 0.5] [9.6, 0.3]]'
# shape = Shape(template)

template = Template(template)
# rand_index = sort(rand(1:100,10))
# xp = range(0, 2π, 100)
# yp = random_noise([0.1], 1:0.1:4, -10:1:10, xp, 4)
# template = Template([xp[rand_index] yp[rand_index]])
shape = ClosedShape(circle(0.,0.,sqrt(1),5))

shape = shape*R(45)
h = 0.5
s = 1+2*h/(shape.bb[2]-shape.bb[1])
# buffer_shape = shape*s


fig = Figure(size = (800, 800))
ax = Axis(fig[1,1], aspect=DataAspect())

# lines!(ax, template.points)
# lines!(ax, template.centered.points)

# ax2 = Axis(fig[1,2], aspect=1)

lines!(ax, shape.points)

fractal = fractalize(shape,4, noise_params)

buffer = shape*s
lines!(ax, fractal.points)
lines!(ax, buffer.points)

# mask = inpoly2(grid, fractal.points, fractal.edges)[:,1]
# maskb = inpoly2(grid, buffer.points, buffer.edges)[:,1]
# maskb -= mask

# mask = reshape(mask, length(y), length(x))
# maskb = reshape(maskb, length(y), length(x))

# # # # fractal = fractalize(fractal, template)
# # # lines!(ax, fractal.points)
# # # heatmap!(ax2, x, y, mask')
# heatmap!(ax2, x, y, maskb')

display(fig)


# x = sort(rand(range(0, 4π, 20), 10))
# y = sin.(0.6*x)

# scatterlines(x,y)
