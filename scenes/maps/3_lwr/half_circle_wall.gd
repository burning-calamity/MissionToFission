extends Node2D

@export var radius: float = 100
@export var segments: int = 16
@export var arc_degrees: float = 180.0  # Half circle
@export var wall_thickness: float = 100.0
@export var wall_length: float = 15.0
@export var skip_first_and_last: bool = false

func _ready():
	rebuild_wall()

func rebuild_wall() -> void:
	for child in get_children():
		if child is StaticBody2D:
			remove_child(child)
			child.queue_free()
	create_half_circle_wall()
	queue_redraw()

func get_effective_segments() -> int:
	return maxi(segments, int(ceil(deg_to_rad(arc_degrees) * radius / 28.0)))

func get_segment_wall_length() -> float:
	return maxf(wall_length, deg_to_rad(arc_degrees) * radius / get_effective_segments() * 1.35)

func create_half_circle_wall():
	var effective_segments: int = get_effective_segments()
	var angle_step = deg_to_rad(arc_degrees) / effective_segments
	var start_angle = deg_to_rad(90.0 - arc_degrees / 2.0)
	var segment_wall_length: float = get_segment_wall_length()

	for i in range(effective_segments + 1):
		if skip_first_and_last:
			if i == 0 or i == effective_segments:
				continue
		var angle = start_angle + i * angle_step
		var pos = Vector2(cos(angle), sin(angle)) * radius

		var wall = StaticBody2D.new()
		wall.position = pos
		wall.rotation = angle + PI / 2.0

		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.extents = Vector2(segment_wall_length / 2.0, wall_thickness / 2.0)
		shape.shape = rect

		wall.add_child(shape)
		add_child(wall)


func _draw():
	var arc_color = Color.BLACK

	# Draw the arc visually to match the collider
	var start_angle = 0
	draw_arc(Vector2.ZERO, radius, start_angle, PI, get_effective_segments() * 5, arc_color, 20)
