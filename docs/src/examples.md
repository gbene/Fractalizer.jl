## [1. Custom template](@id examples)

Create a fractalized Shape using a custom template. In this case the shape is also the template.

```@example
using CairoMakie #hide
using Fractalizer



template_points = [[0., 0.] [1.0,1.0] [3.2, 1.0] [4.2, -0.5] [4.5, -0.9] [7.4, -1.2] [8,-0.7] [8.8,0.0] [9.0, 0.5] [9.6, 0.3]]' # Here the matrix is transposed because we want Nx2  

template = Template(template_points)
shape1 = Shape(template_points)

shape2 = MakeRing(0.,0.,sqrt(1),5)


fig = Figure(size = (800, 800))
fig2 = Figure(size = (800, 800))
ax5 = Axis(fig2[1,1], aspect=DataAspect())

ax = Axis(fig[1,1],  title= "Depth 1")
ax2 = Axis(fig[1,2], title= "Depth 4")
ax3 = Axis(fig[2,1])
ax4 = Axis(fig[2,2])

lines!(ax, shape1.points)
lines!(ax2, shape1.points)
lines!(ax3, shape2.points)
lines!(ax4, shape2.points)


fractal1 = fractalize(shape1, template) # Apply template only once
fractal2 = fractalize(shape1, template, 4) # Apply template 4 times
fractal3 = fractalize(shape2, template)
fractal4 = fractalize(shape2, template, 4)

lines!(ax, fractal1.points)
lines!(ax2, fractal2.points)
lines!(ax3, fractal3.points)
lines!(ax4, fractal4.points)

save("../src/assets/examples/ex1.png", fig); sleep(0.5);nothing #hide
```
![](assets/examples/ex1.png)


## 2. Random template

Create a fractalized Shape using a random template. In this case the same random template will be applied to each segment of the Shape.

```@example
using CairoMakie #hide
using Fractalizer


noise_params = NoiseParams(0.1:0.1, 1.0:1:10.0, -10.0:1:10.0, 100, 4, 10)

template = random_template(noise_params)

shape1 = Shape(template.points)

shape2 = MakeRing(0.,0.,sqrt(1),5)

fig = Figure(size = (800, 800))
ax = Axis(fig[1,1],  title= "Depth 1")
ax2 = Axis(fig[1,2], title= "Depth 4")
ax3 = Axis(fig[2,1])
ax4 = Axis(fig[2,2])

lines!(ax, shape1.points)
lines!(ax2, shape1.points)
lines!(ax3, shape2.points)
lines!(ax4, shape2.points)


fractal1 = fractalize(shape1, template)
fractal2 = fractalize(shape1, template, 4)
fractal3 = fractalize(shape2, template)
fractal4 = fractalize(shape2, template, 4)

lines!(ax, fractal1.points)
lines!(ax2, fractal2.points)
lines!(ax3, fractal3.points)
lines!(ax4, fractal4.points)

save("../src/assets/examples/ex2.png", fig); sleep(0.5); nothing #hide
```
![](assets/examples/ex2.png)

## 3. No template

Create a fractalized Shape using random templates for each segment

```@example
using CairoMakie #hide
using Fractalizer



noise_params = NoiseParams(0.1:0.1, 1.0:1:10.0, -10.0:1:10.0, 100, 4, 10)
shape_points = [[0., 0.] [1.0,1.0] [3.2, 1.0] [4.2, -0.5] [4.5, -0.9] [7.4, -1.2] [8,-0.7] [8.8,0.0] [9.0, 0.5] [9.6, 0.3]]'

shape1 = Shape(shape_points)
shape2 = MakeRing(0.,0.,sqrt(1),5)
shape2 = shape2 * R(-30)


fig = Figure(size = (800, 800))
ax = Axis(fig[1,1], title="Depth 1")
ax2 = Axis(fig[1,2], title="Depth 4")
ax3 = Axis(fig[2,1])
ax4 = Axis(fig[2,2])

lines!(ax, shape1.points)
lines!(ax2, shape1.points)
lines!(ax3, shape2.points)
lines!(ax4, shape2.points)


fractal1 = fractalize(shape1, noise_params)
fractal2 = fractalize(shape1, noise_params, 4)

fractal3 = fractalize(shape2, noise_params)
fractal4 = fractalize(shape2, noise_params, 4)

lines!(ax, fractal1.points)
lines!(ax2, fractal2.points)
lines!(ax3, fractal3.points)
lines!(ax4, fractal4.points)

save("../src/assets/examples/ex3.png", fig); nothing #hide
```
![](assets/examples/ex3.png)
