extends Node2D

@export var radius: float = 100
@export var segments: int = 16
@export var arc_degrees: float = 180.0  # Half circle
@export var wall_thickness: float = 100.0
@export var wall_length: float = 15.0

func _ready():
	create_half_circle_wall()

func create_half_circle_wall():
	var angle_step = deg_to_rad(arc_degrees) / segments
	var start_angle = deg_to_rad(90.0 - arc_degrees / 2.0)

	for i in range(segments + 1):
		var angle = start_angle + i * angle_step
		var pos = Vector2(cos(angle), sin(angle)) * radius

		var wall = StaticBody2D.new()
		wall.position = pos
		wall.rotation = angle

		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.extents = Vector2(wall_length / 2.0, wall_thickness / 2.0)
		shape.shape = rect

		wall.add_child(shape)
		add_child(wall)


func _draw():
	var arc_color = Color.BLACK

	# Draw the arc visually to match the collider
	var start_angle = 0
	draw_arc(Vector2.ZERO, radius, start_angle, 3.14, segments*5, arc_color, 20)
