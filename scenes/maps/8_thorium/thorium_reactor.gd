extends Node2D
class_name ThoriumReactor

var x_grid_range: int = 24
var y_grid_range: int = 12
var ctlrod_spacer: int = 3
var show_tutorial_text: bool = false
var game_mode: bool = false

func _ready() -> void:
	globals.reset_game_var()
	Atom.enable_moderation = true
	Atom.enable_xenon = true
	Atom.enrich_percent = 0.88
	Atom.instant_enrich_chance = 0.30
	Atom.become_xenon_later_chance = 0.08
	Atom.spont_emis_time = 1.25
	Water.cool_of_speed = 22
	Water.moderation_strength = 0.92
	Water.water_absorb_chance = 0.04
	Neutron.enable_moderation = true
	GameRunner.goal = 190
	GameRunner.margin_error = 140
	GameRunner.game_mode_enabled = game_mode
	GameRunner.game_not_started = game_mode

	get_parent().get_node("Control").show()
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Layer2").visible = not game_mode
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Tree").visible = not game_mode
	get_parent().get_node("State").show()
	get_parent().get_node("GameScore").visible = game_mode

	get_parent().build_grid_and_center(x_grid_range, y_grid_range, true, true, false, true, ctlrod_spacer, true, true)

	if show_tutorial_text:
		add_tutorial_label()

func uses_water_on_expansion() -> bool:
	return true

func uses_moderator_rods_on_expansion() -> bool:
	return true

func get_expansion_control_rod_spacer() -> int:
	return ctlrod_spacer

func uses_xenon_upgrades() -> bool:
	return true

func add_tutorial_label() -> void:
	var label := Label.new()
	label.position = Vector2(120, 760)
	label.size = Vector2(980, 170)
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	label.text = "Thorium Tutorial\nThorium-style fuel is forgiving: xenon chance is lower and the safety margin is wider, but delayed neutrons arrive more slowly."
	add_child(label)
