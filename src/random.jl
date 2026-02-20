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
        if seed != 0
            Random.seed!(seed)
        end
        new(amplitude_range, frequency_range, phase_range, resolution, iterations, nsamples, seed)
    end


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
