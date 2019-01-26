extends Spatial

#Loading stuff
var previous_level = ""
var loader
var wait_frames
var time_max = 50 #max ms to lock main thread on loading levels

func _ready():
	load_level("Town")

func _process(delta):
	if loader:
		process_loading()
		return
		
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		return

func process_loading():
	if wait_frames > 0:
		wait_frames -= 1
		return
		
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			var s = loader.get_resource()
			var node = s.instance()
			node.name = previous_level
			
			add_child(node)

			var l = get_node("Loading_Text")
			l.set_visible(false)
			
			loader = null
			
			break
		elif err == OK:
			update_progress()
		else:
			show_error()
			loader = null
			break

func load_level(level_name):
	loader = ResourceLoader.load_interactive("res://levels/" + level_name + ".tscn")
	if !loader:
		show_error()
		return
	
	var l = get_node("Loading_Text")
	l.set_visible(true)
	l.set_text("Loading " + level_name)
	
	if previous_level != "":
		var level = get_node(previous_level)
		if level:
			level.queue_free()
			
	previous_level = level_name
	
	wait_frames = 1
	
func update_progress():
	#eventually, do something neat here
	get_node("Loading_Text").set_text("Loading " + previous_level + " [" + (str(loader.get_stage()) + " / " + str(loader.get_stage_count())) + "]")
	print(str(loader.get_stage()) + " / " + str(loader.get_stage_count()))
	