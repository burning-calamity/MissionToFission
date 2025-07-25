extends Area2D

@export var pump_strength: float = 1

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body is Water:
			var global_rot = global_rotation_degrees 
			var radians = deg_to_rad(global_rot)
			var pump_direction = Vector2(cos(radians), sin(radians)).normalized()
			var force = pump_direction * pump_strength
			body.apply_force(force) 
