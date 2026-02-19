abstract type AbstractShape end
abstract type AbstractTemplate end



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


    function Shape(centroid, npoints, segment_lengths, segment_angles, points, xs, ys, bb, edges)
        new(centroid, npoints, segment_lengths, segment_angles, points, xs, ys, bb, edges)
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

        new(centroid, npoints, nsegments, segment_lengths, segment_angles, segment_centers, segment_normals, points, edges, bb, xs, ys)
    end

end

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


    function ClosedShape(centroid, npoints, segment_lengths, segment_angles, points, xs, ys, bb, edges)
        new(centroid, npoints, segment_lengths, segment_angles, points, xs, ys, bb, edges)
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

        new(centroid, npoints, nsegments, segment_lengths, segment_angles, segment_centers, segment_normals, points, edges, bb, xs, ys)
    end

end
