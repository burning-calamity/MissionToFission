extends Node2D
# grid settings
var x_grid_range: int = 30
var y_grid_range: int = 15
var margin: int = 60
var wall_scene:PackedScene = load("res://scenes/fission_objects/container.tscn")
var turbine_speed = 0
var container_nodes: Array[Node] = []

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
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Layer2").show()
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Tree").show()
	get_parent().get_node("State").show()
	get_parent().get_node("GameScore").hide()
	
	var cam = get_parent().get_node("Camera2D")
	cam.zoom.x = 0.7
	cam.zoom.y = 0.7
	
	
	get_parent().build_grid_and_center(x_grid_range, y_grid_range, true, true, false, true, 3, false, true)
	ensure_reactor_grid_exists()
	call_deferred("fit_camera_to_reactor")
	
	# cam.position.y = - 10000
	
	
func ensure_reactor_grid_exists() -> void:
	if get_tree().get_nodes_in_group("atoms").is_empty():
		get_parent().build_grid_and_center(x_grid_range, y_grid_range, true, true, false, true, 3, false, true, true)

func on_reactor_grid_changed() -> void:
	resize_chamber_to_reactor()
	call_deferred("fit_camera_to_reactor")

func fit_camera_to_reactor() -> void:
	if get_parent().has_method("auto_zoom_to_reactor"):
		get_parent().call("auto_zoom_to_reactor")

func resize_chamber_to_reactor() -> void:
	# Keep the LWR chamber large enough for expanded atom grids without rebuilding every frame.
	var chamber_margin: float = 20.0
	var grid_width: float = maxf(GameRunner.x_row_build * GameRunner.margin + GameRunner.margin * 4, 2200.0)
	var chamber_half_height: float = maxf((GameRunner.y_row_build * GameRunner.margin) / 2.0 + GameRunner.margin, 460.0)

	for container in container_nodes:
		container.queue_free()
	container_nodes.clear()

	_set_half_circle("HalfCircleWall", grid_width, chamber_half_height, false)
	_set_half_circle("HalfCircleWalInner", grid_width, chamber_half_height, true)
	$Turbine.position = Vector2(grid_width + 329.0, chamber_half_height + chamber_margin - 9.0)
	get_node("Area2D-heat-exhanger/CollisionShape2D").position = $Turbine.position - Vector2(21.0, 12.0)

	_add_container_wall(Vector2(0, chamber_half_height + chamber_margin), chamber_half_height, 10, 90)
	_add_container_wall(Vector2(grid_width, chamber_half_height + chamber_margin - 5), chamber_half_height, 10, -90)
	_add_container_wall(Vector2(grid_width / 2.0, 10), grid_width / 2.0 + 10, 10, 180)
	_add_container_wall(Vector2(grid_width / 2.0, 20 + 2.0 * chamber_half_height), grid_width / 2.0 + 10, 10, 0)

func _set_half_circle(node_path: NodePath, chamber_width: float, chamber_half_height: float, skip_edges: bool) -> void:
	var half_circle = get_node(node_path)
	half_circle.position = Vector2(chamber_width, chamber_half_height + 15.0)
	half_circle.radius = chamber_half_height + 5.0 if not skip_edges else maxf(200.0, chamber_half_height * 0.45)
	half_circle.skip_first_and_last = skip_edges

func _add_container_wall(pos: Vector2, height_to_set: float, width_to_set: float, rot: float) -> void:
	var new_container: Node = wall_scene.instantiate()
	new_container.set_stats(pos, height_to_set, width_to_set, rot)
	container_nodes.append(new_container)
	add_child(new_container)


func _on_area_2_dheatexhanger_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and body is Water:
		turbine_speed += body.temp
		body.set_temperature(0)
		
func _process(delta: float) -> void:
	$Turbine.rotation_degrees =  fmod($Turbine.rotation_degrees + turbine_speed * delta, 360.0) 
	turbine_speed = clamp(turbine_speed-0.5, 0, 100)
