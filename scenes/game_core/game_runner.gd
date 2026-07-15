extends Node

class_name GameRunner

static var map_to_load: String = "res://scenes/maps/1_basic_reactor/basic_reactor.tscn"
static var map_loaded:Node = null
static var neutron_on_click: bool = true


# get fission objects
var neutron_scene:PackedScene = load("res://scenes/fission_objects/neutron.tscn")
var atom_scene:PackedScene = load("res://scenes/fission_objects/atom.tscn")
var controlRod_scene:PackedScene = load("res://scenes/fission_objects/controlRod.tscn")
var moderator_scene:PackedScene = load("res://scenes/fission_objects/moderator.tscn")
var water_scene:PackedScene = load("res://scenes/fission_objects/water.tscn")
var zoom_step: float = 0.1
var bottom_ui_margin: float = 110.0

signal toggle_game_paused(is_paused: bool)

# keep track on what grid has been build
static var x_row_build:int = 0 
static var y_row_build:int = 0 
static var margin: float = 60.

# game settings
static var game_mode_enabled: bool = false
static var game_not_started: bool = true
static var goal:int = 400
static var margin_error:int = 100
static var neutron_counter: int = 0
static var difficulty_modifier: float = 1.0
var countdown_till_loss:int = 30 
var countdown_till_upgrade:int = 10 # 1 minutes
static var score_timer:float = 0.

static var end_game_messge: String = "You didn't stay within the power limit. "
var game_paused: bool = false:

	get:
		return game_paused
	set(value): 
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)
		
		

func create_zoom_controls() -> void:
	if has_node("ZoomControls"):
		return
	var canvas := CanvasLayer.new()
	canvas.name = "ZoomControls"
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	panel.offset_left = -185
	panel.offset_top = -bottom_ui_margin - 50
	panel.offset_right = 185
	panel.offset_bottom = -bottom_ui_margin
	canvas.add_child(panel)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var zoom_out_button := Button.new()
	zoom_out_button.text = "Zoom -"
	zoom_out_button.pressed.connect(_on_zoom_out_pressed)
	row.add_child(zoom_out_button)

	var auto_zoom_button := Button.new()
	auto_zoom_button.text = "Auto Zoom"
	auto_zoom_button.pressed.connect(_on_auto_zoom_pressed)
	row.add_child(auto_zoom_button)

	var zoom_in_button := Button.new()
	zoom_in_button.text = "Zoom +"
	zoom_in_button.pressed.connect(_on_zoom_in_pressed)
	row.add_child(zoom_in_button)

func _on_zoom_out_pressed() -> void:
	set_camera_zoom($Camera2D.zoom.x - zoom_step)

func _on_zoom_in_pressed() -> void:
	set_camera_zoom($Camera2D.zoom.x + zoom_step)

func _on_auto_zoom_pressed() -> void:
	auto_zoom_to_reactor()

func set_camera_zoom(new_zoom: float) -> void:
	var clamped_zoom: float = clampf(new_zoom, 0.25, 2.0)
	$Camera2D.zoom = Vector2(clamped_zoom, clamped_zoom)

func auto_zoom_to_reactor() -> void:
	var atoms: Array[Node] = get_tree().get_nodes_in_group("atoms")
	if atoms.is_empty():
		return
	var min_pos: Vector2 = atoms[0].global_position
	var max_pos: Vector2 = atoms[0].global_position
	for atom in atoms:
		min_pos.x = minf(min_pos.x, atom.global_position.x)
		min_pos.y = minf(min_pos.y, atom.global_position.y)
		max_pos.x = maxf(max_pos.x, atom.global_position.x)
		max_pos.y = maxf(max_pos.y, atom.global_position.y)
	var reactor_padding := Vector2(margin * 4, margin * 4)
	var reactor_size: Vector2 = max_pos - min_pos + reactor_padding
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var target_zoom: float = minf(viewport_size.x / reactor_size.x, viewport_size.y / reactor_size.y)
	set_camera_zoom(target_zoom)
	var clamped_zoom: float = $Camera2D.zoom.x
	var reactor_center: Vector2 = (min_pos + max_pos) / 2.0
	$Camera2D.position = reactor_center - (viewport_size / (2.0 * clamped_zoom))

func _unhandled_input(event:InputEvent) -> void:
	# close program on esc button
	if event.is_action_pressed("ui_cancel"):
		if $pauseMenu.can_pause:
			game_paused = !game_paused
	
	if event is InputEventMouseButton and not event.is_pressed() and not game_paused and neutron_on_click:		
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var new_neutron:Node = neutron_scene.instantiate()
				new_neutron.initialize($Camera2D.get_global_mouse_position()) 
				add_child(new_neutron) 


# load map on ready
func _ready() -> void:
	# Load the scene
	var scene:Resource = load(self.map_to_load)
	
	# Instantiate the scene and Add the instance to the current scene
	map_loaded = scene.instantiate()
	add_child(map_loaded)
	$Control/Control/MarginContainer/VBoxContainer/Tree.set_vals()
	# tween in map 
	var tween:Tween = get_tree().create_tween()
	tween.set_ease(Tween.EaseType.EASE_OUT)
	tween.set_trans(Tween.TransitionType.TRANS_CUBIC)
	tween.tween_property($Camera2D, "offset:y", 0, 0.8)
	$SceneFader.fade_out()	
	create_zoom_controls()

	
	# set timers and settings
	$loss_timer.wait_time = countdown_till_loss
	$upgrade_timer.wait_time = countdown_till_upgrade
	_on_check_box_enrich_toggled(true)
	_on_check_box_spontain_neutron_emis_toggled(true)

	
	if game_mode_enabled:
		get_node("GameScore").show()
	else:
		get_node("GameScore").hide()
	


func _process(_delta: float) -> void:
	game_logic(_delta)
	update_hud()
	
	# pan camera 
	# var direction = 0.0
	# var cam = $Camera2D
	# if Input.is_action_pressed("a"):
	# 	direction -= 1.0
	# if Input.is_action_pressed("d"):
	# 	direction += 1.0

	# cam.position.x += direction * 500 * _delta

func game_logic(dt:float) -> void:
	
	# check if game should start
	if game_mode_enabled and game_not_started:
		if neutron_counter >= goal - margin_error:
			game_mode_enabled = true
			game_not_started = false
			$upgrade_timer.start()
			
	# if game is running, add score
	if game_mode_enabled and !game_paused and !game_not_started:
		score_timer += dt
		
		# check if you are out of bounds, then start loose timer
		var out_of_bounds_neutrons: bool = neutron_counter < goal - margin_error or neutron_counter > goal + margin_error
		if out_of_bounds_neutrons and $loss_timer.is_stopped():
			$loss_timer.start()
			globals.play(preload("res://assets/sounds/error.wav"))
			
			# display bar 
			var reason:String = ""
			if neutron_counter < goal - margin_error:
				reason = "Reactor is stalling!"
			else:
				reason = "Reactor is too active!"
			$GameScore.show_lose(reason)
			
		# stop loose timer if you recovered neutrons activity
		if !$loss_timer.is_stopped() and !out_of_bounds_neutrons:
				$loss_timer.stop()
				
				# hide bar
				$GameScore.hide_lose()
				
func update_hud() -> void:
	'''
	This function updates the game HUD / visuals. Such as erichiment percent, the goal and so on.
	'''
	# TODO move this into the own script
	if Engine.get_physics_frames() % 15 == 1:

		# update game counter (score and such)
		if game_mode_enabled and $GameScore/GameScore.is_visible_in_tree():
			$GameScore.update_hud(
				self.score_timer,
				self.countdown_till_upgrade,
				self.countdown_till_loss,
				$upgrade_timer.time_left,
				$loss_timer.time_left,
			)
			
		# update neutron bar
		if $State/State.is_visible_in_tree():
			$State/State.set_current_value(neutron_counter)
		

		# Update enrich percent shower 
		if $Control/Control.is_visible_in_tree():
			# TODO this should be in it's own script and node
			var percent: float =  (float(Atom.enriched_present)/float(Atom.enriched_present + Atom.unenriched_present)) * 100
			$Control/Control/MarginContainer/VBoxContainer/Layer1/Enrich_bar.value = percent
			$Control/Control/MarginContainer/VBoxContainer/Layer1/Enrich_bar/Label.text = "Enrichment: " + '%.1f' % percent + "%"
			
			$Control/Control/MarginContainer/VBoxContainer/Layer1/enable_ctrl_rods.button_pressed = ControlRod.enable_auomatic
			$Control/Control/MarginContainer/VBoxContainer/Layer2/CheckBox_enrich.text = "Auto enrich " + str((1 - Atom.enrich_percent) * 100) + "%"
			$Control/Control/MarginContainer/VBoxContainer/Layer2/CheckBox_spontain_neutron_emis.button_pressed = Atom.enable_sponteniues_neutrons
			
func _on_check_box_enrich_toggled(toggled_on: bool) -> void:
	'''
	Starts auomatic enrichment of atoms
	'''
	$Control/Control/MarginContainer/VBoxContainer/Layer2/CheckBox_enrich.button_pressed = toggled_on
	if toggled_on:
		$enrich_timer.wait_time = Atom.enrich_speed
		$enrich_timer.start()
		Atom.enrich_check()
	else:
		$enrich_timer.stop()
		
		
func _on_enrich_timer_timeout() -> void:
	if Atom.enable_enrich:
		Atom.enrich_check()


func _on_check_box_spontain_neutron_emis_toggled(toggled_on: bool) -> void:
	Atom.enable_sponteniues_neutrons = toggled_on
	$Control/Control/MarginContainer/VBoxContainer/Layer2/CheckBox_spontain_neutron_emis.button_pressed = toggled_on
	if toggled_on:
		var atoms: Array[Node] = get_tree().get_nodes_in_group("atoms")
		for atom in atoms:
			if not atom.is_enriched:
				atom.start_spont_neutron_emission()


func build_grid_and_center(
		x_grid:int,
		y_grid:int,
		add_atoms:bool=true,
		add_ctrl:bool=true,
		encriched:bool=false,
		keep_enrich_percent:bool=true,
		ctlrod_spacer:int = 3,
		add_moderator:bool = false,
		add_water:bool=false,
		ignore_build:bool=false,
		expander:bool=false, 
	) -> void:
	'''
	builds or add atoms and control rods to grid and camera will center it. 
	'''
	var x_range:Array = []
	var y_range:Array = []
	
	if not ignore_build:
		x_range = range(x_row_build, x_grid)
		y_range = range(y_row_build, y_grid)
		
		# hack to reuse function to expand reatpr 
		if expander:
			if x_range == []:
				x_range = range(0, x_grid)
			if y_range == []:
				y_range = range(0, y_grid)
				if x_range[0] % ctlrod_spacer == 0 and add_ctrl and expander:
					var new_controlRod:Node = controlRod_scene.instantiate()
					new_controlRod.initialize(Vector2(margin + margin*x_range[0] +0.5*margin, 0)) 
					add_child(new_controlRod)
				
				if x_range[0] % ctlrod_spacer == 2 and add_moderator and expander:
					var new_moderator:Node = moderator_scene.instantiate()
					new_moderator.initialize(Vector2(margin + margin*x_range[0] +0.5*margin, 0)) 
					add_child(new_moderator)
		# store what has been build:
		x_row_build = x_grid
		y_row_build = y_grid
	else:
		x_range = range(0, x_grid)
		y_range = range(0, y_grid)
		
	for x:int in x_range:
		for y:int in y_range:
			
			if add_atoms:
				var new_atom:Node = atom_scene.instantiate()
				new_atom.initialize(Vector2(margin + margin*x, margin + margin*y), encriched, keep_enrich_percent) 
				add_child(new_atom) 
				
			if add_water:
				var new_water:Node = water_scene.instantiate()
				new_water.initialize(Vector2(margin + margin*x, margin + margin*y)) 
				add_child(new_water) 
		
		if x % ctlrod_spacer == 0 and add_ctrl and not expander:
			var new_controlRod:Node = controlRod_scene.instantiate()
			new_controlRod.initialize(Vector2(margin + margin*x +0.5*margin, 0)) 
			add_child(new_controlRod)
			
		if x % ctlrod_spacer == 2 and add_moderator and not expander:
			var new_moderator:Node = moderator_scene.instantiate()
			new_moderator.initialize(Vector2(margin + margin*x +0.5*margin, 0)) 
			add_child(new_moderator)


	if map_loaded != null and map_loaded.has_method("on_reactor_grid_changed"):
		map_loaded.call("on_reactor_grid_changed")

	# tween camera to center newly build grids of atoms. Only x position at the moment
	center_cam_atoms()
	

func center_cam_atoms() -> void:
	var atoms: Array[Node] = get_tree().get_nodes_in_group("atoms")
	var atom_x_positons: Array = []
	for atom in atoms:
		atom_x_positons.append(atom.global_position[0])
	var center_x: float = (atom_x_positons.min() + atom_x_positons.max())/2
	var tween:Tween = get_tree().create_tween()
	tween.set_ease(Tween.EaseType.EASE_OUT)
	tween.set_trans(Tween.TransitionType.TRANS_CUBIC)
	tween.tween_property($Camera2D, "position", Vector2(center_x -1920/2., 0), 1)
	
	# also update ctr rods 
	ControlRod.update_control_rods()
	Moderator.update_mods()	
	
func lost() -> void:
	''' 
	Pop up message, save score, exit game. "size/viewport_width"
	'''
	game_paused = true
	game_mode_enabled = false
	$pauseMenu.game_over_display(score_timer)


func _on_loss_timer_timeout() -> void:
	lost()

# dict of possbilites for upgrades:
# TODO import this from physics changer and append the game margin things now itøs duplciated

var upgrade_dict:Dictionary = {
	"↑ Delayed Neutrons": [
		faster_delaed_neutrons,
		"Increases the ammount of random neutrons releaed by waste material"
	],
	"↑ Speed Enrichment": [
		faster_uranium_enrichment,
		"Increases the speed of the Uranium235 enrichment"
	],
	"↓ Control Rods Speed ": [
		slower_moving_control_rods,
		"Decreases the speed of the control rods"
	],
	"↑ Activity Goal": [
		higher_neutron_goal,
		"Increases the reactivity goal of the reactor"
	],
	"↓ Activity Error Margin": [
		smaller_neutron_margin,
		"Decreases the error margin of the neutron activity goal"
	],
	"↑ Enrichment Percent": [
		higher_enrichment_percent,
		"Allows the reactor to be enriched to higher grade"
	],
	"↑ Enrichment Chance": [
		higher_enrichment_chance,
		"Increases the chance an atom will be enriched isntantly after fission"
	],
}

var helper_upgrade_dict:Dictionary = {
	"↑ Control Rods Speed": [
		faster_control_rods,
		"Rare easy-mode helper: control rods move faster"
	],
	"↑ Activity Error Margin": [
		larger_neutron_margin,
		"Rare easy-mode helper: gives more room around the activity goal"
	],
	"↓ Activity Goal": [
		lower_neutron_goal,
		"Rare easy-mode helper: lowers the target reactor activity"
	],
}

var helper_upgrade_dict_rbmk:Dictionary = {
	"↓ Xenon chance": [
		lower_xenon_chance,
		"Rare easy-mode helper: lowers the chance that waste becomes xenon"
	],
	"↑ Water flow": [
		water_flow_increase,
		"Rare easy-mode helper: water cools faster"
	],
	"↓ Water absorb chance": [
		water_absorb_chance_decrease,
		"Rare easy-mode helper: water absorbs fewer neutrons"
	],
}

var upgrade_dict_rbmk:Dictionary = {
	"↑ Xenon chance": [
		higher_xenon_chance,
		"Increases the chance an atom will be transmute into xenon after fission"
	],
	"↓ Water flow": [
		water_flow_decrease,
		"Decreasese the ammount of water flowing, meaning water will cool of slower"
	],
	"↑ Water absorb chance": [
		water_absorb_chance,
		"Increases the chance water will absorb neutrons"
	],
}

func _reactor_uses_water() -> bool:
	if map_loaded != null and map_loaded.has_method("uses_water_on_expansion"):
		return bool(map_loaded.call("uses_water_on_expansion"))
	return Atom.enable_moderation

func _reactor_uses_moderator_rods() -> bool:
	if map_loaded != null and map_loaded.has_method("uses_moderator_rods_on_expansion"):
		return bool(map_loaded.call("uses_moderator_rods_on_expansion"))
	return Atom.enable_moderation

func _reactor_control_rod_spacer() -> int:
	if map_loaded != null and map_loaded.has_method("get_expansion_control_rod_spacer"):
		return int(map_loaded.call("get_expansion_control_rod_spacer"))
	return 4 if Atom.enable_moderation else 3

func _remove_water_upgrade_choices(upgrades: Dictionary) -> void:
	upgrades.erase("↓ Water flow")
	upgrades.erase("↑ Water absorb chance")
	upgrades.erase("↑ Water flow")
	upgrades.erase("↓ Water absorb chance")

func _build_available_upgrades(include_helpers: bool) -> Dictionary:
	var available_upgrades: Dictionary = upgrade_dict.duplicate()
	if Atom.enable_moderation:
		available_upgrades.merge(upgrade_dict_rbmk)
	if include_helpers:
		available_upgrades.merge(helper_upgrade_dict)
		if Atom.enable_moderation:
			available_upgrades.merge(helper_upgrade_dict_rbmk)
	if not _reactor_uses_water():
		_remove_water_upgrade_choices(available_upgrades)
	return available_upgrades

func _on_upgrade_timer_timeout() -> void:
	'''
	generates 3 random upgrades and calls the pop up to ask whcih one user want
	'''
	
	game_paused = true
	var available_upgrades: Dictionary = _build_available_upgrades(false)
	var keys:Array = available_upgrades.keys()
	keys.shuffle()
	var random_keys:Array = keys.slice(0, 2)

	var helper_chance: float = clampf((1.0 - difficulty_modifier) * 0.5, 0.0, 0.25)
	if randf() < helper_chance:
		var helper_upgrades: Dictionary = helper_upgrade_dict.duplicate()
		if Atom.enable_moderation:
			helper_upgrades.merge(helper_upgrade_dict_rbmk)
		if not _reactor_uses_water():
			_remove_water_upgrade_choices(helper_upgrades)
		var helper_keys: Array = helper_upgrades.keys()
		if not helper_keys.is_empty():
			helper_keys.shuffle()
			var helper_key: String = str(helper_keys[0])
			available_upgrades.merge(helper_upgrades)
			random_keys[randi() % random_keys.size()] = helper_key

	$pauseMenu.upgrade_game_mode(random_keys, available_upgrades)
	

func call_upgrade(key:String) -> void:
	'''
	thhis function is called from the pop up, it will call the function to activate the user choice
	'''
	
	var available_upgrades: Dictionary = _build_available_upgrades(true)
	available_upgrades[key][0].call()
	var add_x:int = 0
	var add_y:int = 0
	if float(x_row_build) / (y_row_build) > 1.6: # add only either row or colm
		add_y += 1
	else:
		add_x += 1
	var expansion_add_water: bool = _reactor_uses_water()
	var expansion_add_moderator: bool = _reactor_uses_moderator_rods()
	var expansion_ctlrod_spacer: int = _reactor_control_rod_spacer()
	build_grid_and_center(
		x_row_build + add_x,
		y_row_build + add_y,
		true,
		true,
		true,
		false,
		expansion_ctlrod_spacer,
		expansion_add_moderator,
		expansion_add_water,
		false,
		true
	)

func make_bigger_reactor() -> void:
	'''
	expands the reactor size with one row or one coloumn and centers it
	'''
	
	if float(x_row_build) / (y_row_build) > 1.6: # add only either row or colm
		for x in range(0, x_row_build):
			var new_atom:Node = atom_scene.instantiate()
			new_atom.initialize(Vector2(margin + margin*x, margin + margin*y_row_build), true) 
			add_child(new_atom) 
		y_row_build += 1
	else:
		for y in range(0, y_row_build):
			var new_atom:Node = atom_scene.instantiate()
			new_atom.initialize(Vector2(margin + margin*x_row_build, margin + margin*y), true) 
			add_child(new_atom) 
			
		if x_row_build % 3 == 0:
			
			# get pos of ctrl rod
			var ctrl_rods: Array = get_tree().get_nodes_in_group("ctrl_rods")
			var ctrl_rods_pos_y_to_mirror: ControlRod =  ctrl_rods[int(not ControlRod.last_created_even)]

			var new_controlRod:Node = controlRod_scene.instantiate()
			new_controlRod.initialize(Vector2(margin + margin*x_row_build +0.5*margin, ctrl_rods_pos_y_to_mirror.global_position.y)) 
			add_child(new_controlRod)
		x_row_build += 1
	
	center_cam_atoms()


func get_scaled_multiplier(base_multiplier: float) -> float:
	return maxf(0.05, 1.0 + ((base_multiplier - 1.0) * difficulty_modifier))

func get_scaled_amount(base_amount: int) -> int:
	return maxi(1, int(round(base_amount * difficulty_modifier)))

func higher_enrichment_percent() -> void:
	Atom.enrich_percent *= get_scaled_multiplier(0.75)
	
func higher_enrichment_chance() -> void:
	Atom.instant_enrich_chance *= get_scaled_multiplier(1.3)
	
func faster_delaed_neutrons() -> void: 
	Atom.spont_emis_time *= get_scaled_multiplier(0.75)
	if Atom.enable_sponteniues_neutrons:
		var atoms: Array[Node] = get_tree().get_nodes_in_group("atoms")
		for atom in atoms:
			if not atom.is_enriched:
				atom.start_spont_neutron_emission()

func slower_moving_control_rods() -> void:
	ControlRod.speed *= get_scaled_multiplier(0.75)
	
func smaller_neutron_margin() -> void:
	self.margin_error -= get_scaled_amount(10)
	

func higher_xenon_chance() -> void:
	Atom.become_xenon_later_chance *= get_scaled_multiplier(1.5)
	
func water_flow_decrease() -> void:
	Water.cool_of_speed *= get_scaled_multiplier(0.5)
	
func water_absorb_chance() -> void:
	Water.water_absorb_chance *= get_scaled_multiplier(1.3)
	
	
func faster_uranium_enrichment() -> void:
	Atom.enrich_speed *= get_scaled_multiplier(0.5)
	$enrich_timer.wait_time = Atom.enrich_speed

	
func higher_neutron_goal() -> void:
	self.goal += get_scaled_amount(50)

func faster_control_rods() -> void:
	ControlRod.speed *= 1.25

func larger_neutron_margin() -> void:
	self.margin_error += 15

func lower_neutron_goal() -> void:
	self.goal = maxi(50, self.goal - 50)

func lower_xenon_chance() -> void:
	Atom.become_xenon_later_chance *= 0.75

func water_flow_increase() -> void:
	Water.cool_of_speed *= 1.25

func water_absorb_chance_decrease() -> void:
	Water.water_absorb_chance *= 0.75

func _on_check_box_enrich_2_toggled(toggled_on: bool) -> void:
	ControlRod.enable_auomatic = toggled_on
