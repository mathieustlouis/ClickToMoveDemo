extends KinematicBody

const MOVE_SPEED = 10
const UP = Vector3(0, 1, 0)

var path = []
var begin = Vector3()
var end = Vector3()

var camera
var camera_translation

onready var nav = get_parent()

func _physics_process(delta):
	if path.size() > 1:
		var to_walk = delta * MOVE_SPEED
		var to_watch = Vector3(0, 1, 0)
		
		while to_walk > 0 and path.size() >= 2:
			var point_from = path[path.size() - 1]
			var point_to = path[path.size() - 2]
			var distance = point_from.distance_to(point_to)
			
			to_watch = (point_to - point_from).normalized()
			
#			collisions detection will happen here but for not it doesn't work
#			if test_move(get_transform(), to_watch):
#				path = []
#				set_process(false)
#				return
				
			if distance <= to_walk:
				path.remove(path.size() - 1)
				to_walk -= distance
			else:
				path[path.size() - 1] = point_from.linear_interpolate(point_to, to_walk / distance)
				to_walk = 0
		
		var at_position = path[path.size() - 1]
		to_watch.y = 0
		
		var new_transform = Transform()
		new_transform.origin = at_position
		new_transform = new_transform.looking_at(at_position + to_watch, UP)
		set_transform(new_transform)
		
		if camera:
			camera.rotation_degrees.y = get_rotation_degrees().y * -1
			var y = get_rotation_degrees().y
			var rad_y = deg2rad(-y)
			
			camera.translation = camera_translation.rotated(UP, rad_y)
		
		if path.size() < 2:
			path = []
			set_process(false)
	else:
		set_process(false)
		
func update_path():
	var points = nav.get_simple_path(begin, end, true)
	path = Array(points)
	path.invert()
	
	set_process(true)

func move(from, to):
	begin = nav.get_closest_point(get_translation())
	end = nav.get_closest_point_to_segment(from, to)

	update_path()