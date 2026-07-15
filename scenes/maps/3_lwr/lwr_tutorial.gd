extends "res://scenes/maps/3_lwr/lwr_simulate.gd"

func _ready() -> void:
	super()
	GameRunner.game_mode_enabled = false
	if has_node("Label"):
		$Label.text = "Light Water Reactor Tutorial\nWater moderates neutrons and carries heat to the turbine. Try changing control rods and watch the activity meter."
