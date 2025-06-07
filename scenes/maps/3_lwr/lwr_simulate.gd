extends Node2D
# grid settings
var x_grid_range: int = 30
var y_grid_range: int = 15
var margin: int = 60
var wall_scene:PackedScene = load("res://scenes/fission_objects/container.tscn")

func _ready() -> void:
	globals.reset_game_var()
	# set map settings 
	# Atom.enrich_percent = 0.5
	Atom.enable_moderation = true
	Atom.enable_xenon = true
	Neutron.enable_moderation = true
	GameRunner.game_mode_enabled = false
	GameRunner.goal = 200 # set this to let ctrl rods  autoamtic aim for something

	
	get_parent().get_node("Control").hide()
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Layer2").hide()
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Tree").hide()
	get_parent().get_node("State").hide()
	get_parent().get_node("GameScore").hide()


	get_parent().build_grid_and_center(x_grid_range, y_grid_range, true, true, false, true, 3, false, true)

	build_countainer()
	
	
func build_countainer():
	# build container 
	
	# sides
	var new_container:Node = wall_scene.instantiate()
	new_container.set_stats(Vector2(0, 480 - 10), 450, 10, 90) 
	add_child(new_container)
	
	# new_container = wall_scene.instantiate()
	# new_container.set_stats(Vector2(1850, 480), 450, 10, -90) 
	# add_child(new_container)
	
	new_container = wall_scene.instantiate()
	new_container.set_stats(Vector2(1850/2, 15), 1850/2, 10, 180) 
	add_child(new_container)
	
	new_container = wall_scene.instantiate()
	new_container.set_stats(Vector2(1850/2, 450*2 + 20), 1850/2, 10, 0) 
	add_child(new_container)
	
