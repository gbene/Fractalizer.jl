module Fractalizer

using LinearAlgebra



include("utils.jl")
include("objects.jl")
include("random.jl")
include("fractalizers.jl")

function Base.:*(x::T, y::Float64) where T<: AbstractShape
    return T(x.points*y)
end

function Base.:*(x::T, y::Matrix) where T<: AbstractShape
    return T(x.points*y)
end

export circle, Template, Shape, ClosedShape, fractalize, NoiseParams, random_template, R


end
