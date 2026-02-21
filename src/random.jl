

"""
    NoiseParams

Type used to encapsulate the random settings for generating random templates.

### Fields

- `amplitude_range::AbstractRange` -- Range of amplitudes to be used
- `frequency_range::AbstractRange` -- Range of frequency to be used
- `phase_range::AbstractRange` -- Range of phases to be used
- `resolution::Int` -- N of points of the generated random signal
- `iterations::Int` -- N of times that random signals are stacked 
- `nsamples::Int` -- N of samples of the final random template
- `seed::Int` -- seed for random generation


### Examples

- `noise_params = NoiseParams(0.1:0.1, 1.0:1:10.0, -10.0:1:10.0, 100, 4, 10)` -- default constructor, random seed

- `noise_params = NoiseParams(0.1:0.1, 1.0:1:10.0, -10.0:1:10.0, 100, 4, 10, seed=1)` -- default constructor, fixed seed
"""
struct NoiseParams
    amplitude_range::AbstractRange
    frequency_range::AbstractRange
    phase_range::AbstractRange

    resolution::Int
    iterations::Int
    nsamples::Int
    seed::Int

    function NoiseParams(amplitude_range, frequency_range, phase_range, resolution, iterations, nsamples; seed::Int=0)
        if nsamples <= 0
            nsamples = resolution
        end
        new(amplitude_range, frequency_range, phase_range, resolution, iterations, nsamples, seed)
    end


end



"""
    random_template(params::NoiseParams)

Generate a random template given the parameters in NoiseParams

### Input

- `params` -- NoiseParams struct with all the settings for random generation 

### Output

A Template object

### Algorithm

The random template is defined as follows:

1. A random value of amplitude, frequency and phase are picked from the ranges
2. A sine wave in (0,2π) is generated with the picked resolution and the random values
3. A random selection of nsamples are then picked from the signal 

"""
function random_template(params::NoiseParams)

    if params.seed != 0
        Random.seed!(params.seed)
    end

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
