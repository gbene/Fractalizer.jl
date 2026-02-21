abstract type AbstractShape end
abstract type AbstractTemplate end


"""
    CenteredTemplate <: AbstractTemplate

Private type used mainly to store a centered (0,0) and "flat" (inclination=0) copy of a Tamplate.

### Fields

- `centroid::Vector{Float64}` -- [x, y] vector of the coordinates of the centroid of the template
- `npoints::Int` -- Number of points of the template
- `line_length::Float64` -- Length of the template as distance between the first and last point 
- `line_angle::Float64` -- Inclination of the template using the first and last point.  
- `points::Matrix{Float64}` -- nx2 Matrix of points
- `xs::SubArray` -- x coordinates of the points
- `ys::SubArray` -- y coordinates of the points

### Notes
- The main way to use CenteredTemplate is just to give points, the centroid and the line_angle of the Template
- xs and ys are views of points

### Examples

- `CenteredTemplate(points::Matrix, centroid::Vector, line_angle::Float64)` -- most used constructor

"""
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
        line_angle = (atand(vectordet(v, ref), dot(v, ref))+360)%360
        new(centroid, npoints, line_length, line_angle, points, xs, ys)
    end


end


"""
    Template <: AbstractTemplate

Type to encapsulate templates used to fractalize.

### Fields

- `centroid::Vector{Float64}` -- [x, y] vector of the coordinates of the centroid of the template
- `npoints::Int` -- Number of points of the template
- `line_length::Float64` -- Length of the template as distance between the first and last point 
- `line_angle::Float64` -- Inclination of the template using the first and last point.  
- `points::Matrix{Float64}` -- nx2 Matrix of points
- `xs::SubArray` -- x coordinates of the points
- `ys::SubArray` -- y coordinates of the points
- `centered::CenteredTemplate` -- CenteredTemplate copy of the template. This is used to properly scale the template that then is translated to the segment

### Notes
- xs and ys are views of points

### Examples

- `Template(points::Matrix{Float64})` -- most used constructor

"""
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
        line_angle = (atand(vectordet(v, ref), dot(v, ref))+360)%360

        centered = CenteredTemplate(points, centroid, line_angle)
        new(centroid, npoints, line_length, line_angle, points, xs, ys, centered)
    end


end

"""
    Shape <: AbstractShape

Type to encapsulate shapes that need to be fractalized.

### Fields

- `centroid::Vector{Float64}` -- [x, y] vector of the coordinates of the centroid of the shape
- `npoints::Int` -- Number of points of the shape
- `nsegments::Int` -- Number of segments of the shape
- `segment_lengths::Vector{Float64}` -- Lengths of each segment of the shape 
- `segment_angles::Vector{Float64}` -- Azimuthal angle (0,360) of each segment in the shape, with [1,0] as reference 0°.
- `segment_centers::Matrix{Float64}` -- Center of each segment of the shape.  
- `segment_normals::Matrix{Float64}` -- Normals of each segment of the shape.  
- `points::Matrix{Float64}` -- nx2 Matrix of points
- `edges::Matrix{Int}` -- nx2 connectivity Matrix indicating the indexes of the points that define the segment
- `bb::Matrix{Float64}` -- 4x2 Matrix indicating the bounding box of the shape. [[minimum(xs), maximum(xs)] [minimum(ys), maximum(ys)]]
- `xs::SubArray` -- x coordinates of the points
- `ys::SubArray` -- y coordinates of the points
- `l::Float64` -- bounding box length
- `w::Float64` -- bounding box width

### Notes
- xs and ys are views of points

### Examples

- `Shape(points::Matrix{Float64})` -- most used constructor

"""
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
    l::Float64
    w::Float64


    function Shape(centroid, npoints, segment_lengths, segment_angles, points, edges, bb, xs, ys, l, w)
        new(centroid, npoints, segment_lengths, segment_angles, points, edges, bb, xs, ys, l, w)
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


            segment_angles[i]  = (atand(vectordet(v, ref), dot(v, ref))+360)%360
            segment_centers[i, :] = center
            segment_normals[i, :] = normal/norm(normal)


            edges[i,:] = [i, i+1]
        end

        # edges[end,2] = 1

        bb = [[minimum(xs), maximum(xs)] [minimum(ys), maximum(ys)]]
        l = bb[2]-bb[1]
        w = bb[4]-bb[3]


        new(centroid, npoints, nsegments, segment_lengths, segment_angles, segment_centers, segment_normals, points, edges, bb, xs, ys, l, w)
    end

end

"""
    ClosedShape <: AbstractShape

Type to encapsulate closed shapes that need to be fractalized (i.e. rings or closed polygons).

### Fields

- `centroid::Vector{Float64}` -- [x, y] vector of the coordinates of the centroid of the shape
- `npoints::Int` -- Number of points of the shape
- `nsegments::Int` -- Number of segments of the shape
- `segment_lengths::Vector{Float64}` -- Lengths of each segment of the shape 
- `segment_angles::Vector{Float64}` -- Azimuthal angle (0,360) of each segment in the shape, with [1,0] as reference 0°.
- `segment_centers::Matrix{Float64}` -- Center of each segment of the shape.  
- `segment_normals::Matrix{Float64}` -- Normals of each segment of the shape.  
- `points::Matrix{Float64}` -- nx2 Matrix of points
- `edges::Matrix{Int}` -- nx2 connectivity Matrix indicating the indexes of the points that define the segment
- `bb::Matrix{Float64}` -- 4x2 Matrix indicating the bounding box of the shape. [[minimum(xs), maximum(xs)] [minimum(ys), maximum(ys)]]
- `xs::SubArray` -- x coordinates of the points
- `ys::SubArray` -- y coordinates of the points
- `l::Float64` -- bounding box length
- `w::Float64` -- bounding box width

### Notes
- `xs` and `ys` are views of `points`
- The last and first points of the shape coincide. This is automatically done when inputting a matrix of points. 

### Examples

- `ClosedShape(points::Matrix{Float64})` -- most used constructor

"""
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
    l::Float64
    w::Float64

    function ClosedShape(centroid, npoints, segment_lengths, segment_angles, points, edges, bb, xs, ys, l, w)
        new(centroid, npoints, segment_lengths, segment_angles, points, edges, bb, xs, ys, l, w)
    end

    function ClosedShape(points)
        # absmax(x) = x[argmax(abs.(x))]
        points[end, :] = points[1,:]

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


            segment_angles[i]  = (atand(vectordet(v, ref), dot(v, ref))+360)%360
            segment_centers[i, :] = center
            segment_normals[i, :] = normal/norm(normal)


            edges[i,:] = [i, i+1]
        end

        edges[end,2] = 1

        bb = [[minimum(xs), maximum(xs)] [minimum(ys), maximum(ys)]]
        l = bb[2]-bb[1]
        w = bb[4]-bb[3]
        new(centroid, npoints, nsegments, segment_lengths, segment_angles, segment_centers, segment_normals, points, edges, bb, xs, ys, l, w)
    end

end
