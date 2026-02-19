using GLMakie
using Fractalizer
using PolygonInbounds

x = -2:0.005:2
y = -2:0.005:2

grid = [vec(x'.* ones(length(y))) vec(y .* ones(length(x))')]

fig = Figure(size = (800, 800))
ax = Axis(fig[1,1], aspect=DataAspect())

sg = SliderGrid(fig[2,1],
                (label="Amplitude", range=0.1:0.01:1, startvalue=0.1),
                (label="Frequency", range=1.:0.1:10., startvalue=0.1),
                (label="Phase", range=-10.0:1:10.0, startvalue=0),)

sliderobs = [s.value for s in sg.sliders]

fractal_points = lift(sliderobs...) do slidervals...
        amplitude = slidervals[1]
        freq = slidervals[2]
        phase = slidervals[3]

        noise_params = NoiseParams(amplitude:amplitude, freq:freq, phase:phase, 100, 4, 10)

        shape = ClosedShape(makecircle(0.,0.,sqrt(1),5))
        fractal = fractalize(shape,  noise_params, 4)


        return fractal.points

end


lines!(ax, shape.points)
lines!(ax, fractal_points)



display(fig)
