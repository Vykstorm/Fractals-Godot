extends Node2D

# This script generates mandelbrot fractals


## EXPORTS

# Points will be rotated about the graph's center with this amount (in degrees)
export (float) var fractal_rotation = 0.0

# All the points in the graph will be translated with this amount of units on the imaginary axis
export (float) var fractal_shear = 0;

# Color of the fractals
export (Color) var fractal_color = Color(1.0, 0.0, 0.0)

# This variable increase/decrease fractal color brightness
export (float) var fractal_brightness = 1.0


# This parameter modifies the mandelbrot's equation
# The function is defined normally as: f(xi) = f(xi-1)^2 + c where c is
# a complex number, and f(0) = 0
# If this parameter is b, the function is defined instead as:
# f(xi) = f(xi-1)^b + c
export (float) var branch_factor = 4

# Parameter to calculate fractals. As this values increases, more
# chances to have more points inside the mandelbrot set.
export (float) var divergence_limit = 50


# Maximum number of recursive iterations per point in the complex plane
# (per pixel) to determine if such point is inside the mandelbrot's set or
# not. The computational cost increases as this value becomes higher but
# it also adds more precision and detail to the image.
export (int) var convergence_iter_limit = 20


# This value change the colors used to plot the fractals. Must be a value within
# the range [0, 1]
# You can modify the palette colors for custom coloring. The image is located
# in res://images/palette.png
export (float) var palette_index = 0

# This is the point to follow when zomming in/out in the mandelbrot'set
export (Vector2) var center = Vector2(0, 0)

# Resolution (number of pixels) of the mandelbrot's set.
export (Vector2) var size = Vector2(125, 125)



# This value indicates the zoom level of the camera
export (float) var zoom_level = 0

# This variable indicates the maximum camera's zooming speed
export (float) var max_zoom_speed = 0.75

# This parameter indicates the camera's zomming acceleration
export (float) var zoom_acceleration = 0.35

# This parameter indicates the camera's zooming acceleration when
# zoom action changes.
export (float) var zoom_brake = 0.75

# This parameter indicates the zoom action which can take one of the next values:
# -1 = zooming out
# 0 = dont change zoom level
# 1 = zooming in
export (int) var zoom_action = 0


# Parameter that controls the maximum speed of the camera.
# The final speed of the camera will be this value multiplied by
# the fractal's current scale
export (float) var max_move_speed = 0.08

export (float) var move_acceleration = 0.25

export (float) var move_brake = 0.15

# Moving direction of the camera
export (Vector2) var move_direction = Vector2(0, 0)


# Set this value to true to rotate the camera over time
export (bool) var spin = false

# Maximum angular speed of the camera (in degrees per second)
export (float) var max_angular_speed = 10.0

export (float) var angular_acceleration = 10.0
export (float) var angular_brake = 8.0


# When setting this to true, the user can change simulation parameters with the keyboard/mouse controls
export (bool) var controls_enabled = true


## HELPER VARIABLES & FUNCTIONS

# Camera's current velocity
var move_velocity = Vector2(0, 0)

# Camera's zoom current speed
var zoom_speed = 0

# Camera's current angular speed
var angular_speed = 0

# Current fractal scale (computed automatically given the camera zoom level
var fractal_scale




func set_param(name, value):
	# Adjust a shader parameter
	self.material.set_shader_param(name, value)

	
	
func update_params():
	# Set shader program parameters
	set_param('scale', fractal_scale)
	set_param('rotation', deg2rad(fractal_rotation))
	set_param('shear', fractal_shear)
	set_param('branch_factor', branch_factor)
	set_param('divergence_limit', divergence_limit)
	set_param('convergence_iter_limit', convergence_iter_limit)
	set_param('center', center)
	set_param('palette_index', palette_index)
	
	set_param('hue', fractal_color.h)
	set_param('saturation', fractal_color.s)
	set_param('alpha', fractal_color.a)
	set_param('brightness_factor', fractal_brightness)

func _process(delta):
	
	if controls_enabled:
		# Update move direction
		move_direction = Vector2(0, 0)
		if Input.is_action_pressed("move-down"):
			move_direction.y -= 1
		if Input.is_action_pressed("move-up"):
			move_direction.y += 1
		if Input.is_action_pressed("move-left"):
			move_direction.x += 1
		if Input.is_action_pressed("move-right"):
			move_direction.x -= 1
		if move_direction.length_squared() > 1:
			move_direction = move_direction.normalized()
			
		# Update zoom action
		zoom_action = 0
		if Input.is_action_pressed("zoom-in"):
			zoom_action = 1
		if Input.is_action_pressed("zoom-out"):
			zoom_action = -1
	
	
	# Update camera's zoom speed
	if zoom_action != 0:
		var zoom_acc = zoom_acceleration * zoom_action
		if zoom_acc * zoom_speed < 0:
			zoom_acc += sign(zoom_acc) * zoom_brake
		zoom_speed += zoom_acc * delta
		zoom_speed = clamp(zoom_speed, -max_zoom_speed, max_zoom_speed)
		
	elif abs(zoom_speed) > 0:
		var zoom_acc = -zoom_brake * sign(zoom_speed) * max_zoom_speed
		zoom_speed += zoom_acc * delta
		if zoom_acc * zoom_speed > 0:
			zoom_speed = 0
				
	# Update camera's zoom level
	zoom_level += zoom_speed * delta


	# Compute fractal scale
	fractal_scale = 1.0 / (0.1 * pow(2, zoom_level))


	# Update camera's angular speed
	if spin:
		angular_speed += angular_acceleration * delta
		angular_speed = min(angular_speed, max_angular_speed)
	elif angular_speed > 0:
		angular_speed -= angular_brake * delta
		if angular_speed < 0:
			angular_speed = 0
		
	# Update camera's rotation
	fractal_rotation += angular_speed * delta
	fractal_rotation = fmod(fractal_rotation, 360)

	# Update camera's velocity
	if move_direction.x != 0 or move_direction.y != 0:
		var move_acc = move_acceleration * move_direction.rotated(deg2rad(fractal_rotation))
		move_velocity += move_acc * delta
		if move_velocity.length() > max_move_speed:
			move_velocity = move_velocity.normalized() * max_move_speed
	
	elif move_velocity.length_squared() > 0:
		var move_acc = -move_brake * move_velocity.normalized()
		move_velocity += move_acc * delta
		if move_velocity.dot(move_acc) > 0:
			move_velocity = Vector2(0, 0)

	
	# Update camera's look at point (center)
	center += move_velocity * fractal_scale * delta


	# Refresh shader program params
	update_params()


func _ready():
	update()

func _draw():
	# Just draw a filled rectange to mark the pixels to be used to draw
	# fractals in the shader program
	draw_rect(Rect2(-size / 2, size), Color(1, 1, 1, 1), true)