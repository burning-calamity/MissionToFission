extends Node2D
class_name MoltenSaltReactor

var x_grid_range: int = 26
var y_grid_range: int = 11
var ctlrod_spacer: int = 4
var show_tutorial_text: bool = false
var game_mode: bool = false

func _ready() -> void:
	globals.reset_game_var()
	Atom.enable_moderation = true
	Atom.enable_xenon = true
	Atom.enrich_percent = 0.78
	Atom.instant_enrich_chance = 0.22
	Atom.become_xenon_later_chance = 0.10
	Water.cool_of_speed = 35
	Water.moderation_strength = 0.80
	Water.water_absorb_chance = 0.03
	Neutron.enable_moderation = true
	GameRunner.goal = 220
	GameRunner.margin_error = 130
	GameRunner.game_mode_enabled = game_mode
	GameRunner.game_not_started = game_mode

	get_parent().get_node("Control").show()
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Layer2").show()
	get_parent().get_node("Control/Control/MarginContainer/VBoxContainer/Tree").show()
	get_parent().get_node("State").show()
	get_parent().get_node("GameScore").visible = game_mode

	get_parent().build_grid_and_center(x_grid_range, y_grid_range, true, true, false, true, ctlrod_spacer, true, true)

	if show_tutorial_text:
		add_tutorial_label()

func add_tutorial_label() -> void:
	var label := Label.new()
	label.position = Vector2(120, 760)
	label.size = Vector2(980, 170)
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	label.text = "Molten Salt Tutorial\nFuel and coolant behavior is smoother here: xenon is lower, water absorption is lower, and the wider margin gives you time to stabilize the reactor."
	add_child(label)
