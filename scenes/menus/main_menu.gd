extends Control

var atom_scene:PackedScene = load("res://scenes/fission_objects/atom.tscn")
var pending_game_mode_map: String = ""
var pending_game_mode_scene: String = ""
var difficulty_slider: HSlider
var difficulty_label: Label
var difficulty_popup: PanelContainer
var difficulty_overlay: ColorRect

func _ready() -> void:
	$MarginContainer.position[1] = -932.5
	configure_settings()
	animate_in()
	
	$UiButtonSound.connect_button_ui()
	create_difficulty_selector()
	
	var margin:float = 65.
	for x in range(-1, 30):
		for y in range(-2, 17):
			if randf() > 0.90:
				var new_atom:Node = atom_scene.instantiate()
				new_atom.initialize(Vector2(margin + margin*x, margin + margin*y), randi_range(0, 1),) 
				add_child(new_atom) 

	# connect not implimented buttons
	var buttons_404: Array[Node] = get_tree().get_nodes_in_group("404")
	for button in buttons_404:
		button.pressed.connect(_on_404_pressed)
		
	# instantly load new map for debug
	# animate_out("res://scenes/maps/3_lwr/lwr_simulate.tscn", "res://scenes/game_core/game_runner.tscn")

func configure_settings() -> void:
	globals.reset_game_var()
	Atom.enable_sponteniues_neutrons = true

func animate_in() -> void:
	configure_settings()
	Dialogic.end_timeline() # Prevents text boxes from showing when exiting tutorial
	$fly_in_sound.play()
	$SceneFader.fade_out()
	var tween:Tween = get_tree().create_tween()
	tween.set_ease(Tween.EaseType.EASE_OUT)
	tween.set_trans(Tween.TransitionType.TRANS_CUBIC)
	tween.tween_property($MarginContainer, "position:y", 0, 0.8)
	

	
func create_difficulty_selector() -> void:
	difficulty_overlay = ColorRect.new()
	difficulty_overlay.hide()
	difficulty_overlay.z_index = 10
	difficulty_overlay.color = Color(0, 0, 0, 0.35)
	difficulty_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	difficulty_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(difficulty_overlay)

	difficulty_popup = PanelContainer.new()
	difficulty_popup.custom_minimum_size = Vector2(520, 260)
	difficulty_popup.set_anchors_preset(Control.PRESET_CENTER)
	difficulty_popup.offset_left = -260
	difficulty_popup.offset_top = -130
	difficulty_popup.offset_right = 260
	difficulty_popup.offset_bottom = 130
	difficulty_overlay.add_child(difficulty_popup)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	difficulty_popup.add_child(box)

	var title := Label.new()
	title.text = "Choose Game Mode Difficulty"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	box.add_child(title)

	difficulty_label = Label.new()
	difficulty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(difficulty_label)

	difficulty_slider = HSlider.new()
	difficulty_slider.min_value = 0.5
	difficulty_slider.max_value = 1.5
	difficulty_slider.step = 0.1
	difficulty_slider.value = GameRunner.difficulty_modifier
	difficulty_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	difficulty_slider.value_changed.connect(_on_difficulty_slider_value_changed)
	box.add_child(difficulty_slider)

	var hint := Label.new()
	hint.text = "Easy adds rare helper choices; hard makes reactor events stronger."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 16)
	box.add_child(button_row)

	var cancel_button := Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(_on_difficulty_cancel_pressed)
	button_row.add_child(cancel_button)

	var start_button := Button.new()
	start_button.text = "Start Game Mode"
	start_button.pressed.connect(_on_difficulty_start_pressed)
	button_row.add_child(start_button)

	_on_difficulty_slider_value_changed(difficulty_slider.value)


func open_difficulty_selector(map_load:String, scene_file:String) -> void:
	pending_game_mode_map = map_load
	pending_game_mode_scene = scene_file
	difficulty_slider.value = GameRunner.difficulty_modifier
	difficulty_overlay.show()


func _on_difficulty_slider_value_changed(value: float) -> void:
	var label := "Normal"
	if value <= 0.7:
		label = "Easy"
	elif value >= 1.3:
		label = "Hard"
	difficulty_label.text = "%s difficulty: %.1fx reactor event strength" % [label, value]


func _on_difficulty_cancel_pressed() -> void:
	difficulty_overlay.hide()
	pending_game_mode_map = ""
	pending_game_mode_scene = ""


func _on_difficulty_start_pressed() -> void:
	if pending_game_mode_map.is_empty() or pending_game_mode_scene.is_empty():
		return
	GameRunner.difficulty_modifier = difficulty_slider.value
	difficulty_overlay.hide()
	animate_out(pending_game_mode_map, pending_game_mode_scene)


func animate_out(map_load:String, scene_file:String) -> void:
	$fly_in_sound.play()
	$SceneFader.fade_in()
	var tween:Tween = get_tree().create_tween()
	tween.set_ease(Tween.EaseType.EASE_OUT)
	tween.set_trans(Tween.TransitionType.TRANS_CUBIC)
	tween.tween_property($Camera2D, "position:y", -1200, 0.8)
	tween.connect("finished", on_tween_finished.bind(map_load, scene_file))
	
	
func on_tween_finished(map_load:String, scene_file:String) -> void:
	globals.reset_game_var()
	GameRunner.map_to_load = map_load
	get_tree().change_scene_to_file(scene_file)
	
func _on_button_quit_pressed() -> void:
	get_tree().quit()

# bad code, select menu
func _on_button_sandbox_pressed() -> void:
	animate_out("res://scenes/maps/misc/sandbox.tscn", "res://scenes/game_core/game_runner.tscn")


func _on_button_credits_pressed() -> void:
	animate_out("res://scenes/maps/2_rbmk/rbmk_reactor.tscn", "res://addons/maaacks_credits_scene/examples/scenes/end_credits/end_credits.tscn")


func _on_button_pressed() -> void:
	animate_out("res://scenes/maps/1_basic_reactor/tutorial.tscn", "res://scenes/game_core/game_runner.tscn")

func _on_button_3_pressed() -> void:
	animate_out("res://scenes/maps/1_basic_reactor/basic_reactor.tscn", "res://scenes/game_core/game_runner.tscn")


func _on_404_pressed() -> void:
	animate_out("res://scenes/game_core/404.tscn", "res://scenes/game_core/game_runner.tscn")

func _on_button_2_pressed() -> void:
	open_difficulty_selector("res://scenes/maps/1_basic_reactor/basic_reactor_game.tscn", "res://scenes/game_core/game_runner.tscn")

# escape on exit
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_simulate_mode_rbmk_pressed() -> void:
	animate_out("res://scenes/maps/2_rbmk/rbmk_reactor.tscn", "res://scenes/game_core/game_runner.tscn")


func _on_tutorial_pressed() -> void:
	animate_out("res://scenes/maps/2_rbmk/tutorial.tscn", "res://scenes/game_core/game_runner.tscn")


func _on_game_mode_rbmk_pressed() -> void:
	open_difficulty_selector("res://scenes/maps/2_rbmk/rbmk_reactor_game.tscn", "res://scenes/game_core/game_runner.tscn")


func _on_simulate_mode_lwr_pressed() -> void:
	animate_out("res://scenes/maps/3_lwr/lwr_simulate.tscn", "res://scenes/game_core/game_runner.tscn")
