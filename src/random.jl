"""
    random_template(params::NoiseParams; prng::DataType=Xoshiro)

Generate a random template given the parameters in NoiseParams

### Input

- `params` -- NoiseParams struct with all the settings for random generation
- `prng`   -- Random generator to use for picking values. Default is Xoshiro

### Output

A `::RandomTemplate` object

### Algorithm

The random template is defined as follows:

1. A random value of amplitude, frequency and phase are picked from the ranges
2. A sine wave in (0,2π) is generated with the picked resolution and the random values
3. A random selection of nsamples are then picked from the signal

"""
function random_template(params::NoiseParams; prng::DataType=Xoshiro)

    old_seeds = params.seeds
    newseeds = Vector{Int}(undef, 4)
    for i in eachindex(old_seeds)
        if isnothing(old_seeds[i])
            newseeds[i] = rand(Int)
        else
            newseeds[i] = old_seeds[i]
        end
    end

    params = NoiseParams(params, newseeds)

    amplitude_range = params.amplitude_range
    frequency_range = params.frequency_range
    phase_range = params.frequency_range
    resolution = params.resolution
    iter = params.iterations
    ampl_seed, freq_seed, phas_seed, index_seed = params.seeds

    nsamples = params.nsamples

    xp = range(0, 2π, resolution)
    yp = zeros(length(xp))
    rand_index = sort(rand(prng(index_seed), 1:resolution, nsamples))

    for i in 1:iter
        rand_a = rand(prng(ampl_seed), amplitude_range)
        rand_f = rand(prng(freq_seed), frequency_range)
        rand_p = rand(prng(phas_seed), phase_range)
        @. yp += rand_a*sin(rand_f*xp+rand_p)
    end
    template = RandomTemplate([xp[rand_index] yp[rand_index]], params)
    return template

end
