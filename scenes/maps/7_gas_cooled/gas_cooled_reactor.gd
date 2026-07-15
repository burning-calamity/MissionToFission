extends Node2D
class_name GasCooledReactor

var x_grid_range: int = 28
var y_grid_range: int = 12
var ctlrod_spacer: int = 4
var show_tutorial_text: bool = false
var game_mode: bool = false

func _ready() -> void:
	globals.reset_game_var()
	Atom.enable_moderation = true
	Atom.enable_xenon = true
	Atom.enrich_percent = 0.82
	Atom.instant_enrich_chance = 0.18
	Atom.become_xenon_later_chance = 0.16
	Water.cool_of_speed = 8
	Water.moderation_strength = 0.55
	Water.water_absorb_chance = 0.01
	Neutron.enable_moderation = true
	GameRunner.goal = 240
	GameRunner.margin_error = 115
	GameRunner.game_mode_enabled = game_mode
	GameRunner.game_not_started = game_mode

	get_parent().get_node("Control").show()
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Layer2").visible = not game_mode
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Tree").visible = not game_mode
	get_parent().get_node("State").show()
	get_parent().get_node("GameScore").visible = game_mode

	get_parent().build_grid_and_center(x_grid_range, y_grid_range, true, true, false, true, ctlrod_spacer, true, false)

	if show_tutorial_text:
		add_tutorial_label()

func uses_water_on_expansion() -> bool:
	return false

func add_tutorial_label() -> void:
	var label := Label.new()
	label.position = Vector2(120, 750)
	label.size = Vector2(980, 170)
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	label.text = "Gas-Cooled Tutorial\nGas cooling has low absorption and weak moderation. The reactor responds more slowly, so use control rods early and watch the activity trend."
	add_child(label)
