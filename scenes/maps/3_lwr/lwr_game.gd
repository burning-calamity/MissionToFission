extends "res://scenes/maps/3_lwr/lwr_simulate.gd"

func _ready() -> void:
	super()
	GameRunner.game_mode_enabled = true
	GameRunner.game_not_started = true
	GameRunner.goal = 150
	GameRunner.margin_error = 100
	get_parent().get_node("GameScore").show()
	if has_node("Label"):
		$Label.text = "Light Water Reactor Game Mode\nKeep neutron activity near the goal while water removes heat."
