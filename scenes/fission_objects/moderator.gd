extends Area2D
class_name Moderator

@export var width: float = 10
@export var color:Color = Color("1A1A1A")

static var min_height: float = 200
static var max_height: float = - 420
static var rod_height: float = 900

var rectangle_shape:Shape2D =  null

static var _registered_nodes: Array = []
func _ready() -> void:
	# set collisohape to set varables
	rectangle_shape =  $CollisionShape2D.shape as RectangleShape2D
	rectangle_shape.extents = Vector2(self.width/2., self.rod_height/2.) 
	
	# enable collison check w neutrons
	set_collision_mask_value(globals.moderator_neutron_slot, true)
	
	_registered_nodes.append(self)
	update_mods()
	
	position.y = max_height

func _draw() -> void:
	draw_rect(Rect2(-self.width/2., -self.rod_height/2., self.width, self.rod_height), Color("ffffff"))
	draw_rect(Rect2(-self.width/2.+1, -self.rod_height/2.+1, self.width+1, self.rod_height+1), self.color, false)
	rectangle_shape.extents = Vector2(self.width/2., self.rod_height/2.) 

func initialize(pos_to_set:Vector2) -> void:
	position = Vector2(pos_to_set[0], pos_to_set[1])
	
func _on_area_entered(area: Area2D) -> void:
	if area is Neutron:
		area.current_velocity.x = -area.current_velocity.x
		if area.is_fast:
			area.is_fast = false
			area.current_speed = area.thermal_speed
			area.current_velocity = area.current_velocity.normalized() * area.current_speed
			# stop collidng width moderator:
			area.set_collision_layer_value(globals.moderator_neutron_slot, false)
			# start colliding width atoms:
			area.set_collision_layer_value(globals.neutrol_collide_slot, true)
			area.queue_redraw()

		
static func update_mods() -> void:
	rod_height = GameRunner.y_row_build * GameRunner.margin 
	min_height = -rod_height/2 + GameRunner.margin/2
	max_height = rod_height/2 + GameRunner.margin/2
	
	# que redraw
	for moderator: CanvasItem in _registered_nodes:
		moderator.position.y = rod_height /2  + GameRunner.margin/2
		moderator.queue_redraw()
