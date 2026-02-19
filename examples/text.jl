using GLMakie
using Fractalizer
using Luxor

function text_to_shape(text::String)
    d = Drawing()
    fontsize(16)
    # fontface("monospace")
    shapes = Vector{ClosedShape}(undef, length(text))
    spacing=8
    s = 0.
    for c in eachindex(text)
        t = text[c]
        textpath(string(t),Luxor.Point(s,0.))
        p = pathtopoly()
        points = [b for a in p for b in a]
        mat = Matrix{Float64}(undef, length(points), 2)
        for i in eachindex(points)
            mat[i,:] = [points[i].x, abs(points[i].y)]

        end
        # mat[end,:] = mat[1,:]

        shapes[c] = ClosedShape(mat)
        s+=spacing
    end
    return shapes
end

noise_params = NoiseParams(0.1:0.1, 1.0:1:10.0, -10.0:1:10.0, 100, 4, 10)



shapes = text_to_shape("Fractalize.jl")
shape = shapes[2]
fract_shapes = fractalize.(shapes, [noise_params], [4])


fig = Figure(size = (800, 800))
ax = Axis(fig[1,1], aspect=DataAspect())


for i in eachindex(shapes)
    # lines!(ax, shapes[i].points)
    lines!(ax, fract_shapes[i].points)
end
# noise_params = NoiseParams(0.1:0.1, 1.0:1:10.0, -10.0:1:10.0, 100, 4, 10)

# shape1 = Shape(shape_points)
# shape2 = ClosedShape(circle(0.,0.,sqrt(1),5))


# fig = Figure(size = (800, 800))
# ax = Axis(fig[1,1], aspect=DataAspect())
# ax2 = Axis(fig[1,2], aspect=DataAspect())
# ax3 = Axis(fig[2,1], aspect=DataAspect())
# ax4 = Axis(fig[2,2], aspect=DataAspect())

# lines!(ax, shape1.points)
# lines!(ax2, shape2.points)
# lines!(ax3, shape1.points)
# lines!(ax4, shape2.points)


# fractal1 = fractalize(shape1, noise_params)
# fractal2 = fractalize(shape2, noise_params)

# fractal3 = fractalize(shape1, 4, noise_params)
# fractal4 = fractalize(shape2, 4, noise_params)

# lines!(ax, fractal1.points)
# lines!(ax2, fractal2.points)
# lines!(ax3, fractal3.points)
# lines!(ax4, fractal4.points)

display(fig)
