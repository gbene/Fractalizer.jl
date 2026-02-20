
"""
    fractalize(shape::T, template::Template) where where T <: AbstractShape
    fractalize(shape::T, noise_params::NoiseParams) where where T <: AbstractShape
    fractalize(shape::T, template::Template, iter::Int) where where T <: AbstractShape
    fractalize(shape::T, noise_params::NoiseParams, iter::Int) where where T <: AbstractShape


Fractalize an AbstractShape using either a template or random noise with additional cumulative steps.

### Input

- shape -- AbstractShape to fractalize
- template -- Template used to fractalize
- noise_params -- Settings for the random noise 
- iter -- Number of times to apply the fractalization algorithm

### Output

A new AbstractShape of the same concrete type of shape.

### Algorithm

The algorithm works by scaling and rotating the template for each segment of the shape. The new shape will result in the combination of the scaled and rotated templates at each segment. This process can be repeated multiple times to get a fractal where each segment of the new shape will be modified following the template. To scale we calculate the length of the segment and the line_length of the template and scale the template depending on this value. The translation of the template is done so that the first point of the template coincides with the first point of the segment.
    
When using the noise_params each segment will have a unique noise signal i.e. each segment will have a unique template. 
"""
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

function fractalize(shape::T, template::Template, iter::Int) where T <: AbstractShape
    fractal = fractalize(shape, template)

    for i in 1:iter-1
        fractal = fractalize(fractal, template)

    end
    return fractal
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


function fractalize(shape::T, noise_params::NoiseParams, iter::Int) where T <: AbstractShape
    fractal = fractalize(shape, noise_params)

    for i in 1:iter-1
        fractal = fractalize(fractal, noise_params)

    end
    return fractal
end
