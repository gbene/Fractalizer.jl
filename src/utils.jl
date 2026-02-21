"""
    vectordet(x::Vector, y::Vector)

Private function used to calculate the det of two vectors

    ``det = x{1}y{2} - x{2}*y{1}``

"""
function vectordet(x::Vector, y::Vector)
    return x[1]*y[2] - x[2]*y[1]
end


"""
    makering(x0, y0, r, npoints)

Create a ring.

### Input

- `x0` -- x center of the ring
- `y0` -- y center of the ring
- `r` -- radius of the ring
- `npoints` -- n of points of the ring

### Output

A ClosedShape object

### Notes

Since the output is a closed shape, the number of sides is 1-npoints. This means that

- triangle -> npoints = 4
- square -> npoints = 5
- pentagon -> npoints = 6
- ...
"""
function makering(x0, y0, r, npoints)
    θ = range(0,2π,length=npoints)
    p = @. [x0+r*sin(θ) y0+r*cos(θ)]
    p[end,:] = p[1,:]
    return p
end


"""
    remove_overlapping(x::Matrix{Float64})

Private function used to remove points that are very closed (using ≈). 
    
### Notes

This is mainly used to clean up the final ClosedShape. There is an imposed rule where the first point 
is always marked as non overlapping.
"""
function remove_overlapping(x::Matrix{Float64})
    mask = vec(reduce(&, x[1:end-1,:] .≈ x[2:end,:], dims=2))
    pushfirst!(mask, false)

    return x[.!mask,:]
end


"""
    R(θ)

2D Rotation matrix for angle θ in degrees.

```math
R(\\theta) = \\begin{bmatrix}

\\cos{\\theta} & \\sin{\\theta}\\\\
-\\sin{\\theta} & \\cos{\\theta}\\\\

\\end{bmatrix}
```

### Input

- θ -- Rotation angle in degrees. 

### Output

2x2 rotation matrix
"""
R(θ) = [[cosd(θ), sind(θ)] [-sind(θ), cosd(θ)]]
