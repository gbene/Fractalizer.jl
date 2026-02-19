using GLMakie
using LinearAlgebra
using PolygonInbounds

abstract type AbstractShape end
abstract type AbstractTemplate end

struct NoiseParams
    amplitude_range::AbstractRange
    frequency_range::AbstractRange
    phase_range::AbstractRange

    resolution::Int
    iterations::Int
    nsamples::Int

    function NoiseParams(amplitude_range, frequency_range, phase_range, resolution, iterations, nsamples)
        if nsamples <= 0
            nsamples = resolution
        end
        new(amplitude_range, frequency_range, phase_range, resolution, iterations, nsamples)
    end


end

struct CenteredTemplate <: AbstractTemplate

    centroid::Vector{Float64}
    npoints::Int
    line_length::Float64
    line_angle::Float64
    points::Matrix{Float64}
    xs::SubArray
    ys::SubArray

    function CenteredTemplate(centroid, npoints, line_length, line_angle, points, xs, ys)
        new(centroid, npoints, line_length, line_angle, points, xs, ys)
    end

    function CenteredTemplate(tpoints, tcentroid, tangle)

        translated_points = tpoints .- tcentroid'
        points = translated_points*R(-tangle)

        xs = view(points, :, 1)
        ys = view(points, :, 2)
        npoints = size(points, 1)
        centroid = vec(sum(points, dims=1)./npoints)
        v = [xs[end]-xs[1], ys[end]-ys[1]]
        ref = [1, 0] # Reference vector for orientation is the x axis

        line_length = norm(v)
        line_angle = (atand(det(v, ref), dot(v, ref))+360)%360
        new(centroid, npoints, line_length, line_angle, points, xs, ys)
    end


end

struct Template <: AbstractTemplate

    centroid::Vector{Float64}
    npoints::Int
    line_length::Float64
    line_angle::Float64
    points::Matrix{Float64}
    xs::SubArray
    ys::SubArray

    centered::CenteredTemplate

    function Template(centroid, npoints, line_length, line_angle, points, xs, ys)
        new(centroid, npoints, line_length, line_angle, points, xs, ys, centered)
    end

    function Template(points)
        xs = view(points, :, 1)
        ys = view(points, :, 2)
        npoints = size(points, 1)
        centroid = vec(sum(points, dims=1)./npoints)
        v = [xs[end]-xs[1], ys[end]-ys[1]]
        ref = [1, 0] # Reference vector for orientation is the x axis

        line_length = norm(v)
        line_angle = (atand(det(v, ref), dot(v, ref))+360)%360

        centered = CenteredTemplate(points, centroid, line_angle)
        new(centroid, npoints, line_length, line_angle, points, xs, ys, centered)
    end


end

struct Shape <: AbstractShape
    centroid::Vector{Float64}
    npoints::Int
    nsegments::Int
    segment_lengths::Vector{Float64}
    segment_angles::Vector{Float64}
    segment_centers::Matrix{Float64}

    segment_normals::Matrix{Float64}

    points::Matrix{Float64}
    edges::Matrix{Int}
    bb::Matrix{Float64}

    xs::SubArray
    ys::SubArray


    function Shape(centroid, npoints, segment_lengths, segment_angles, points, xs, ys, bb, edges)
        new(centroid, npoints, segment_lengths, segment_angles, points, xs, ys, bb, edges)
    end

    function Shape(points)
        # absmax(x) = x[argmax(abs.(x))]

        xs = view(points, :, 1)
        ys = view(points, :, 2)
        npoints = size(points, 1)
        nsegments = npoints-1
        centroid = vec(sum(points, dims=1)./npoints)
        ref = [1, 0] # Reference vector for orientation is the x axis


        segment_lengths = Vector{Float64}(undef, nsegments) #length of each segment
        segment_angles = Vector{Float64}(undef, nsegments)  #direction of each segment
        segment_centers = Matrix{Float64}(undef, nsegments, 2)  #direction of each segment
        segment_normals = Matrix{Float64}(undef, nsegments, 2)  #direction of each segment

        edges = Matrix{Int}(undef, nsegments, 2)

        for i in 1:nsegments
            A = [xs[i], ys[i]]
            B = [xs[i+1], ys[i+1]]
            center = (B .+ A) / 2 #[(xs[i+1]+xs[i])/2, (ys[i+1]+ys[i])/2]

            A .-= center
            B .-= center
            v = B .- A #[xs[i+1]-xs[i], ys[i+1]-ys[i]]
            segment_lengths[i] = norm(v)

            # maxx = argmax(abs, [A[1], B[1]])

            normal = [-v[2], v[1]]


            segment_angles[i]  = (atand(det(v, ref), dot(v, ref))+360)%360
            segment_centers[i, :] = center
            segment_normals[i, :] = normal/norm(normal)


            edges[i,:] = [i, i+1]
        end

        # edges[end,2] = 1

        bb = [[minimum(xs), maximum(xs)] [minimum(ys), maximum(ys)]]

        new(centroid, npoints, nsegments, segment_lengths, segment_angles, segment_centers, segment_normals, points, edges, bb, xs, ys)
    end

end

struct ClosedShape <: AbstractShape

    centroid::Vector{Float64}
    npoints::Int
    nsegments::Int
    segment_lengths::Vector{Float64}
    segment_angles::Vector{Float64}
    segment_centers::Matrix{Float64}

    segment_normals::Matrix{Float64}

    points::Matrix{Float64}
    edges::Matrix{Int}
    bb::Matrix{Float64}

    xs::SubArray
    ys::SubArray


    function ClosedShape(centroid, npoints, segment_lengths, segment_angles, points, xs, ys, bb, edges)
        new(centroid, npoints, segment_lengths, segment_angles, points, xs, ys, bb, edges)
    end

    function ClosedShape(points)
        # absmax(x) = x[argmax(abs.(x))]

        xs = view(points, :, 1)
        ys = view(points, :, 2)
        npoints = size(points, 1)
        nsegments = npoints-1
        centroid = vec(sum(points, dims=1)./npoints)
        ref = [1, 0] # Reference vector for orientation is the x axis


        segment_lengths = Vector{Float64}(undef, nsegments) #length of each segment
        segment_angles = Vector{Float64}(undef, nsegments)  #direction of each segment
        segment_centers = Matrix{Float64}(undef, nsegments, 2)  #direction of each segment
        segment_normals = Matrix{Float64}(undef, nsegments, 2)  #direction of each segment

        edges = Matrix{Int}(undef, nsegments, 2)

        for i in 1:nsegments
            A = [xs[i], ys[i]]
            B = [xs[i+1], ys[i+1]]
            center = (B .+ A) / 2 #[(xs[i+1]+xs[i])/2, (ys[i+1]+ys[i])/2]

            A .-= center
            B .-= center
            v = B .- A #[xs[i+1]-xs[i], ys[i+1]-ys[i]]
            segment_lengths[i] = norm(v)

            # maxx = argmax(abs, [A[1], B[1]])

            normal = [-v[2], v[1]]


            segment_angles[i]  = (atand(det(v, ref), dot(v, ref))+360)%360
            segment_centers[i, :] = center
            segment_normals[i, :] = normal/norm(normal)


            edges[i,:] = [i, i+1]
        end

        points[end, :] = points[1,:]
        edges[end,2] = 1

        bb = [[minimum(xs), maximum(xs)] [minimum(ys), maximum(ys)]]

        new(centroid, npoints, nsegments, segment_lengths, segment_angles, segment_centers, segment_normals, points, edges, bb, xs, ys)
    end

end

function remove_overlapping(x::Matrix{Float64})
    mask = vec(reduce(&, x[1:end-1,:] .≈ x[2:end,:], dims=2))
    pushfirst!(mask, false)

    return x[.!mask,:]
end

function random_template(params::NoiseParams)

    amplitude_range = params.amplitude_range
    frequency_range = params.frequency_range
    phase_range = params.frequency_range
    resolution = params.resolution
    iter = params.iterations

    nsamples = params.nsamples

    rand_index = sort(rand(1:resolution,nsamples))
    xp = range(0, 2π, resolution)
    yp = zeros(length(xp))

    for i in 1:iter
        rand_a = rand(amplitude_range)
        rand_f = rand(frequency_range)
        rand_p = rand(phase_range)
        @. yp += rand_a*sin(rand_f*xp+rand_p)
    end
    template = Template([xp[rand_index] yp[rand_index]])
    return template

end

# function make_buffer(shape::T, h) where T<:AbstractShape
#     bpoints = copy(shape.points)
#     for i in 1:shape.nsegments
#         point_idxs = shape.edges[i,:]

#         bpoints[point_idxs, :] .+= h*shape.segment_normals[i,:]'

#     end
#     return T(bpoints)
# end



function LinearAlgebra.:det(x::Vector, y::Vector)
    return x[1]*y[2] - x[2]*y[1]
end

function Base.:*(x::T, y::Float64) where T<: AbstractShape
    return T(x.points*y)
end

function Base.:*(x::T, y::Matrix) where T<: AbstractShape
    return T(x.points*y)
end


function circle(x0, y0, r, npoints)
    θ = range(0,2π,length=npoints)
    p = @. [x0+r*sin(θ) y0+r*cos(θ)]
    p[end,:] = p[1,:]
    return p
end

function fractalize(shape::T, template::Template) where T <: AbstractShape

    fractal = Matrix{Float64}(undef, shape.nsegments*template.npoints, 2)
    startidx = 1
    endidx = template.npoints

    for i in 1:shape.nsegments

        scaling_factor = shape.segment_lengths[i]/template.line_length
        tc = template.centered
        new_shape = tc.points*R(shape.segment_angles[i])*scaling_factor

        vec = new_shape[1,:] .- shape.points[i,:]

        new_shape = new_shape .- vec'
        new_shape[1,:] = shape.points[i,:]
        new_shape[end,:] = shape.points[i+1,:]

        fractal[startidx:endidx,:] = new_shape

        startidx = endidx+1
        endidx = endidx+template.npoints

    end
    final_points = remove_overlapping(fractal)

    return T(final_points)
end

function fractalize(shape::T, noise_params::NoiseParams) where T <: AbstractShape

    fractal = Matrix{Float64}(undef, shape.nsegments*noise_params.nsamples, 2)
    startidx = 1
    endidx = noise_params.nsamples

    for i in 1:shape.nsegments
        template = random_template(noise_params)

        scaling_factor = shape.segment_lengths[i]/template.line_length
        tc = template.centered
        new_shape = tc.points*R(shape.segment_angles[i])*scaling_factor

        vec = new_shape[1,:] .- shape.points[i,:]

        new_shape = new_shape .- vec'
        new_shape[1,:] = shape.points[i,:]
        new_shape[end,:] = shape.points[i+1,:]
        fractal[startidx:endidx,:] = new_shape
        startidx = endidx+1
        endidx = endidx+template.npoints

    end
    final_points = remove_overlapping(fractal)

    return T(final_points)
end

function fractalize(shape, template, iter::Int)
    fractal = fractalize(shape, template)

    for i in 1:iter-1
        fractal = fractalize(fractal, template)

    end
    return fractal
end
function fractalize(shape, iter::Int, noise_params::NoiseParams)
    fractal = fractalize(shape, noise_params)

    for i in 1:iter-1
        fractal = fractalize(fractal, noise_params)

    end
    return fractal
end

R(θ) = [[cosd(θ), sind(θ)] [-sind(θ), cosd(θ)]]

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
