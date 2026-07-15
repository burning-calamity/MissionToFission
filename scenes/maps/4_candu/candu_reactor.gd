extends Node2D
class_name CanduReactor

var x_grid_range: int = 24
var y_grid_range: int = 10
var ctlrod_spacer: int = 4
var show_tutorial_text: bool = false
var game_mode: bool = false

func _ready() -> void:
	globals.reset_game_var()
	Atom.enable_moderation = true
	Atom.enable_xenon = false
	Atom.enrich_percent = 0.92
	Atom.instant_enrich_chance = 0.12
	Water.moderation_strength = 0.98
	Neutron.enable_moderation = true
	GameRunner.goal = 180
	GameRunner.margin_error = 110
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
	label.size = Vector2(900, 160)
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	label.text = "CANDU Tutorial\nHeavy water moderation lets this reactor run with lower enrichment. Use the control rods and water behavior to stabilize the neutron activity."
	add_child(label)
