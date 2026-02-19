function vectordet(x::Vector, y::Vector)
    return x[1]*y[2] - x[2]*y[1]
end

function circle(x0, y0, r, npoints)
    θ = range(0,2π,length=npoints)
    p = @. [x0+r*sin(θ) y0+r*cos(θ)]
    p[end,:] = p[1,:]
    return p
end

function remove_overlapping(x::Matrix{Float64})
    mask = vec(reduce(&, x[1:end-1,:] .≈ x[2:end,:], dims=2))
    pushfirst!(mask, false)

    return x[.!mask,:]
end

R(θ) = [[cosd(θ), sind(θ)] [-sind(θ), cosd(θ)]]
