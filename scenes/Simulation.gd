extends Node

# This script controls the scene


## EXPORTS



## HELPER VARIABLES

# Sliders to change simulation parameters


onready var sliders = $UI/Control/HBoxContainer/HBoxContainer/Sliders
onready var branch_factor_slider = sliders.get_node('BranchFactor')
onready var shear_slider = sliders.get_node('Shear')
onready var convergence_iter_limit_slider = sliders.get_node('Details')
onready var divergence_limit_slider = sliders.get_node('DivergenceLimit')
onready var brightness_slider = sliders.get_node('Brightness')

onready var rotate_switch = $UI/Control/HBoxContainer/Rotate/CheckButton

# Color picker to change fractal colors
onready var color_picker = $UI/Control/HBoxContainer.get_node('Color/Picker')

# This points to the node that draws the fractals
onready var fractals = $Fractals


## CALLBACKS

func _ready():
	# Set default fractal parameters
	fractals.branch_factor = branch_factor_slider.value
	fractals.fractal_shear = shear_slider.value
	fractals.convergence_iter_limit = convergence_iter_limit_slider.value
	fractals.divergence_limit = divergence_limit_slider.value
	fractals.palette_index = 0.0
	fractals.fractal_color = color_picker.color
	fractals.spin = rotate_switch.pressed
	fractals.fractal_brightness = brightness_slider.value

func _on_branch_factor_changed(value):
	# This is called when grow factor parameter is modified on the UI
	fractals.branch_factor = value

func _on_shear_changed(value):
	# This is called when shear parameter is modified on the UI
	fractals.fractal_shear = value

func _on_converence_iter_limit_changed(value):
	# This is invoked when convergence iteration limit parameter is modified on the UI
	fractals.convergence_iter_limit = value

func _on_divergence_limit_changed(value):
	# This is invoked when divergence limit parameter is modified on the UI
	fractals.divergence_limit = value

func _on_color_changed(color):
	# Called when color changes
	fractals.fractal_color = color

func _on_rotation_toggled(button_pressed):
	# Called when rotation is activated / deactivated
	fractals.spin = button_pressed


func _on_brightness_changed(value):
	# Invoked when brightness changes
	fractals.fractal_brightness = value
