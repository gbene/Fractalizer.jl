using GLMakie

function circle(x0, y0, r, npoints)
    θ = range(0,2π,length=npoints)
    return @. [x0+r*sin(θ) y0+r*cos(θ)] 
end

function fractalize(shape, template)

    centroid = sum(template, dims=1)./10

    template_line_length = sqrt((template[end, 1]-template[1,1])^2+(template[end,2]-template[1,2])^2)
    template_line_angle = atand((template[end, 2]-template[1, 2])/(template[end, 1]-template[1, 1]))


    translated_template = template .- centroid

    # shape = circle(0,0,1,5)

    n_points   = size(shape,1)
    n_segments = n_points-1
    template_npoints = size(template, 1)

    segment_lengths = Vector{Float64}(undef, n_segments) #length of each segment
    segment_angles = Vector{Float64}(undef, n_segments)  #direction of each segment

    for i in 1:n_segments
        segment_lengths[i] = sqrt((shape[i+1, 1]-shape[i,1])^2+(shape[i+1, 2]-shape[i, 2])^2)
        segment_angles[i]  = (atand((shape[i, 2]-shape[i+1, 2])/(shape[i, 1]-shape[i+1, 1])))

    end

    display(segment_angles)


    scaling_factors = segment_lengths/template_line_length # scaling factor for each segment

    fractal = Matrix{Float64}(undef, n_segments*template_npoints, 2)
    startidx = 1
    endidx = template_npoints

    for i in 1:n_segments
        new_shape = translated_template*R(segment_angles[i]-template_line_angle)*scaling_factors[i]

        vec = new_shape[1,:] .- shape[i,:]

        new_shape = new_shape .- vec'
        fractal[startidx:endidx,:] = new_shape
        
        startidx = endidx+1
        endidx = endidx+template_npoints

    end
    return unique(fractal,dims=1)
end



R(θ) = [[cosd(θ), -sind(θ)] [sind(θ), cosd(θ)]]


template = [[0., 0.] [2.0,1.5] [3.4, 1.0] [4.2, -0.5] [4.5, -0.9] [7.4, -1.2] [8,-0.7] [8.8,0.0] [9.0, 0.5] [9.6, 0.4]]'
shape = circle(0,0,1,5)

# x = range(0, 2π, 20)
# shape = [collect(x) sin.(x)]

fig, ax, plt = scatterlines(shape)


fractal = fractalize(shape, template)
scatterlines!(ax, fractal)

# fractal = fractalize(fractal, shape)

# scatterlines!(ax, fractal)


display(fig)


# x = sort(rand(range(0, 4π, 20), 10))
# y = sin.(0.6*x)

# scatterlines(x,y)