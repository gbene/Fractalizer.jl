
"""
    fractalize(shape::T, template::AbstractTemplate) where T <: AbstractShape
    fractalize(shape::T, template::Vector{<:AbstractTemplate}) where T <: AbstractShape
    fractalize(shape::T, template::AbstractTemplate, depth::Int) where T <: AbstractShape
    fractalize(shape::T, template::AbstractTemplate, target_length::Float64) where T <: AbstractShape

    fractalize(shape::T, noise_params::NoiseParams) where T <: AbstractShape
    fractalize(shape::T, noise_params::NoiseParams, depth::Int) where T <: AbstractShape
    fractalize(shape::T, noise_params::NoiseParams, target_length::Float64) where T <: AbstractShape


Fractalize an AbstractShape using either a template or random noise.

### Input

- `shape` -- AbstractShape to fractalize
- `template` -- Template used to fractalize
- `noise_params` -- Settings for the random noise
- `depth` -- Depth of the fractal i.e. number of times that the template is iteratevely applied to the shape
- `target_length` -- Mean semgnet length of the final shape to reach before stopping

### Output

A new `::AbstractShape` of the same concrete type of shape. When using noise_params the random generated templates (`::RandomTemplate`) are returned.

### Algorithm

The algorithm works by scaling and rotating a template for each segment of the shape. The new shape will result in the combination of the scaled and rotated templates at each segment.
This process can be repeated multiple times (depth) to get a fractal where each segment of the new shape will be modified following the template.
To scale the length of the segment and the line_length of the template are calculated. Then the templates are uniformly scaled depending on this value.
The translation of the template is done so that the first point of the template coincides with the first point of the segment.

When using the noise_params each segment will have a unique noise signal i.e. each segment will have a
unique template that will be iteratevely applied to the segment

### Notes

The templates must all have the same number of points.

"""
function fractalize(shape::T, template::AbstractTemplate) where T <: AbstractShape

    fractal = Matrix{Float64}(undef, shape.nsegments*template.npoints, 2)
    startidx = 1
    endidx = template.npoints
    segment_ids = Vector{Int}(undef, (shape.nsegments*template.npoints)-1)


    for i in 1:shape.nsegments

        sid = shape.segment_ids[i]

        scaling_factor = shape.segment_lengths[i]/template.line_length
        tc = template.centered
        new_shape = tc.points*R(shape.segment_angles[i])*scaling_factor

        vec = new_shape[1,:] .- shape.points[i,:]

        new_shape = new_shape .- vec'
        new_shape[1,:] = shape.points[i,:]
        new_shape[end,:] = shape.points[i+1,:]

        fractal[startidx:endidx,:] = new_shape
        segment_ids[startidx:endidx-1] .= sid

        startidx = endidx+1
        endidx = endidx+template.npoints

    end
    final_points, mask = non_overlapping(fractal)
    fshape = T(final_points)

    # fshape.min_template_length[] = minimum(shape.segment_lengths)

    fshape.segment_ids .= segment_ids[mask[2:end]]

    return fshape
end

function fractalize(shape::T, templates::Vector{<:AbstractTemplate}) where T <: AbstractShape

    template_npoints = templates[1].npoints # This assumes that all templates have the same n of points. Maybe a sum over the legths can make it generic
    fractal = Matrix{Float64}(undef, shape.nsegments*template_npoints, 2)
    startidx = 1
    endidx = template_npoints
    segment_ids = Vector{Int}(undef, (shape.nsegments*template_npoints)-1)


    for i in 1:shape.nsegments

        sid = shape.segment_ids[i]
        template = templates[sid]

        scaling_factor = shape.segment_lengths[i]/template.line_length
        tc = template.centered
        new_shape = tc.points*R(shape.segment_angles[i])*scaling_factor

        vec = new_shape[1,:] .- shape.points[i,:]

        new_shape = new_shape .- vec'
        new_shape[1,:] = shape.points[i,:]
        new_shape[end,:] = shape.points[i+1,:]

        fractal[startidx:endidx,:] = new_shape
        segment_ids[startidx:endidx-1] .= sid

        startidx = endidx+1
        endidx = endidx+template.npoints

    end
    final_points, mask = non_overlapping(fractal)
    fshape = T(final_points)

    # fshape.min_template_length[] = minimum(shape.segment_lengths)
    fshape.segment_ids .= segment_ids[mask[2:end]]

    return fshape
end

function fractalize(shape::T, template::AbstractTemplate, depth::Int) where T <: AbstractShape
    fractal = fractalize(shape, template)

    for i in 1:depth-1
        fractal = fractalize(fractal, template)

    end
    return fractal
end

function fractalize(shape::T, templates::Vector{<:AbstractTemplate}, depth::Int) where T <: AbstractShape
    fractal = fractalize(shape, templates)

    for i in 1:depth-1
        fractal = fractalize(fractal, templates)

    end
    return fractal
end

function fractalize(shape::T, template::Template, target_size::Float64) where T <: AbstractShape

    fractal = fractalize(shape, template)

    min_size = fractal.min_template_length[]
    n_iter = 1

    while min_size > target_size
        fractal = fractalize(fractal, template)
        min_size = fractal.min_template_length[]
        n_iter+=1

    end
    println("number of iterations: $n_iter")
    return fractal
end

function fractalize(shape::T, templates::Vector{<:AbstractTemplate}, target_length::Float64) where T <: AbstractShape

    fractal = fractalize(shape, templates)

    n_iter = 1

    while fractal.mean_segment_length > target_length
        fractal = fractalize(fractal, templates)
        n_iter+=1

    end
    println("depth reached: $n_iter")
    return fractal
end


function fractalize(shape::T, noise_params::NoiseParams) where T <: AbstractShape


    templates = [random_template(noise_params) for i in 1:shape.nsegments]
    fractal = fractalize(shape, templates)
    return fractal, templates
end

function fractalize(shape::T, noise_params::NoiseParams, depth::Int) where T <: AbstractShape

    templates = [random_template(noise_params) for i in 1:shape.nsegments]
    fractal = fractalize(shape, templates)

    for i in 1:depth-1
        fractal = fractalize(fractal, templates)

    end
    return fractal, templates
end

function fractalize(shape::T, noise_params::NoiseParams, target_length::Float64) where T <: AbstractShape

    templates = [random_template(noise_params) for i in 1:shape.nsegments]
    fractal = fractalize(shape, templates)

    n_iter = 1
    while fractal.mean_segment_length > target_length
        fractal = fractalize(fractal, templates)
        n_iter+=1
    end
    println("depth reached: $n_iter")
    return fractal, templates
end
