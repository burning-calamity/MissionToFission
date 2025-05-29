extends Node2D
var size_x = 500
var size_y = 10

func _ready() -> void:
	$StaticBody2D/CollisionShape2D.shape.extents.x = size_x
	$StaticBody2D/CollisionShape2D.shape.extents.y = size_y
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(
		$StaticBody2D/CollisionShape2D.position.x - $StaticBody2D/CollisionShape2D.shape.extents.x,
		$StaticBody2D/CollisionShape2D.position.y - $StaticBody2D/CollisionShape2D.shape.extents.y,
		$StaticBody2D/CollisionShape2D.shape.extents.x*2,
		$StaticBody2D/CollisionShape2D.shape.extents.y*2),
		"#000000"
	)

func initialize(pos_to_set:Vector2, size_x, size_y, rotate_deg) -> void:
	position = pos_to_set
	self.size_x = size_x 
	self.size_y = size_y
	rotation = deg_to_rad(rotate_deg)
