extends Node2D
# grid settings
var x_grid_range: int = 30
var y_grid_range: int = 15
var margin: int = 60
var wall_scene:PackedScene = load("res://scenes/fission_objects/container.tscn")
var turbine_speed = 0

func _ready() -> void:
	globals.reset_game_var()
	# set map settings 
	# Atom.enrich_percent = 0.5
	Atom.enable_moderation = true
	Atom.enable_xenon = true
	Neutron.enable_moderation = true
	GameRunner.game_mode_enabled = false
	GameRunner.goal = 200 # set this to let ctrl rods  autoamtic aim for something

	Water.cool_of_speed = 0.1
	Water.moderation_strength = 0.90
	
	get_parent().get_node("Control").show()
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Layer2").hide()
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Tree").hide()
	get_parent().get_node("State").show()
	get_parent().get_node("GameScore").hide()
	
	var cam = get_parent().get_node("Camera2D")
	cam.zoom.x = 0.7
	cam.zoom.y = 0.7



	
	get_parent().build_grid_and_center(x_grid_range, y_grid_range, true, true, false, true, 3, false, true)

	build_countainer()
	
	
	
func build_countainer():
	# build container 
	var height = 460
	var width = 2200
	var margin = 20
	# sides
	var new_container:Node = wall_scene.instantiate()
	new_container.set_stats(Vector2(0, height + margin), height , 10, 90) 
	add_child(new_container)
	
	# new_container = wall_scene.instantiate()
	# new_container.set_stats(Vector2(width, height + margin), height , 10, -90) 
	# add_child(new_container)
	
	new_container = wall_scene.instantiate()
	new_container.set_stats(Vector2(width/2, 10), width/2 + 10, 10, 180) 
	add_child(new_container)
	
	new_container = wall_scene.instantiate()
	new_container.set_stats(Vector2(width/2, 20 + 2*height), width/2 + 10, 10, 0) 
	add_child(new_container)
	
func _draw():
	# draw collision box 
	var rect = Rect2(Vector2(1900, 200), Vector2(400, 600))

	# Draw filled white rectangle
	draw_rect(rect, Color.WHITE, true)

	# Draw black border (outline)
	draw_rect(rect, Color.BLACK, false, 20.0)  # 2.0 is border thickness


func _on_area_2_dheatexhanger_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and body is Water:
		turbine_speed += body.temp
		body.temp = 0
		
func _process(delta: float) -> void:
	$Turbine.rotation_degrees =  fmod($Turbine.rotation_degrees + turbine_speed * delta, 360.0) 
	
	turbine_speed = clamp(turbine_speed-0.5, 0, 100)
