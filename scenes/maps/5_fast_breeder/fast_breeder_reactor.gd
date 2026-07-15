extends Node2D
class_name FastBreederReactor

var x_grid_range: int = 22
var y_grid_range: int = 9
var ctlrod_spacer: int = 5
var show_tutorial_text: bool = false
var game_mode: bool = false

func _ready() -> void:
	globals.reset_game_var()
	Atom.enable_moderation = false
	Atom.enable_xenon = true
	Atom.enrich_percent = 0.65
	Atom.instant_enrich_chance = 0.35
	Atom.become_xenon_later_chance = 0.18
	Neutron.enable_moderation = false
	GameRunner.goal = 260
	GameRunner.margin_error = 90
	GameRunner.game_mode_enabled = game_mode
	GameRunner.game_not_started = game_mode

	get_parent().get_node("Control").show()
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Layer2").visible = not game_mode
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Tree").visible = not game_mode
	get_parent().get_node("State").show()
	get_parent().get_node("GameScore").visible = game_mode

	get_parent().build_grid_and_center(x_grid_range, y_grid_range, true, true, true, false, ctlrod_spacer, false, false)

	if show_tutorial_text:
		add_tutorial_label()

func uses_water_on_expansion() -> bool:
	return false

func uses_moderator_rods_on_expansion() -> bool:
	return false

func get_expansion_control_rod_spacer() -> int:
	return ctlrod_spacer

func uses_xenon_upgrades() -> bool:
	return true

func add_tutorial_label() -> void:
	var label := Label.new()
	label.position = Vector2(120, 700)
	label.size = Vector2(980, 170)
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	label.text = "Fast Breeder Tutorial\nFast reactors skip moderation and run hotter. Keep control rods responsive and watch xenon buildup while the neutron population rises quickly."
	add_child(label)
