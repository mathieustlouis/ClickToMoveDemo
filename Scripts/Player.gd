extends "res://Scripts/Unit.gd"

const RAY_LENGTH = 100

func _ready():
	add_to_group("player")
	
	camera = get_node("Camera")
	camera_translation = camera.translation
	
func _exit_tree():
	remove_from_group("player")
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var from = get_node("Camera").project_ray_origin(event.position)
		var to = from + get_node("Camera").project_ray_normal(event.position) * RAY_LENGTH
		
		move(from, to)