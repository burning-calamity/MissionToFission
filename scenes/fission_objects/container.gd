extends Node2D
var size_x = 800
var size_y = 20

func _ready() -> void:
	pass


func _draw() -> void:
	print("draw_call: ", size_x)
	draw_rect(Rect2(
		- size_x,
		- size_y,
		size_x*2,
		size_y*2),
		"#000000"
	)



func set_stats(pos_to_set:Vector2, asize_x, asize_y, rotate_deg) -> void:
	position = pos_to_set
	size_x = asize_x 
	size_y = asize_y
	rotation = deg_to_rad(rotate_deg)
	
	
	var shape = $StaticBody2D/CollisionShape2D.shape.duplicate()
	shape.extents = Vector2(size_x, size_y)
	$StaticBody2D/CollisionShape2D.shape = shape
	
	$StaticBody2D/CollisionShape2D.shape.extents.x = self.size_x
	$StaticBody2D/CollisionShape2D.shape.extents.y = self.size_y
	queue_redraw()
