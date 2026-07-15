extends RigidBody2D
class_name Water

var height: float = 60
var width: float = 60
var cold_color:Color = Color("DCEEFF")
var hot_color:Color = Color("FF4949")
var gone_color:Color = Color("FFFFFF")
var speed: float = 10
var temp: float = 0.
var last_draw_temp_bucket: int = -1

static var water_absorb_chance: float = 0.05
static var cool_of_speed:float = 15
static var enable_movement:bool = false
static var moderation_strength:float = 0.95


func _ready() -> void:
	# set collisohape to set varables
	# var rectangle_shape:RectangleShape2D =  $CollisionShape2D.shape as RectangleShape2D
	# rectangle_shape.extents = Vector2(self.width/2. - 1, self.height/2. -1) 
	var rectangle_shape:CircleShape2D =  $CollisionShape2D.shape as CircleShape2D
	rectangle_shape.radius = 20
	# enable collison check w neutrons
	set_collision_mask_value(globals.neutrol_collide_slot, true)
	set_collision_mask_value(globals.moderator_neutron_slot, true)
	
	#contact_monitor = true
	#max_contacts_reported = 1
	
	# collide with cylinder
	set_collision_mask_value(18, true)
	

func _draw() -> void:
	var color_draw:Color = self.gone_color
	if self.temp < 100:
		color_draw = self.cold_color.lerp(self.hot_color, self.temp/100)
	draw_rect(Rect2(-self.width/2., -self.height/2., self.width, self.height), color_draw)


func initialize(pos_to_set:Vector2) -> void:
	position = Vector2(pos_to_set[0], pos_to_set[1])
	

func _process(_delta:float) -> void:
	if self.temp <= 0:
		return
	self.temp = clampf(self.temp - (self.cool_of_speed*_delta), 0, 100000000)
	queue_redraw_if_temperature_bucket_changed()
	
	# if self.temp > 0:
	# 	linear_velocity += Vector2(0, - self.temp/1000)


func set_temperature(new_temp: float) -> void:
	self.temp = clampf(new_temp, 0, 100000000)
	queue_redraw_if_temperature_bucket_changed()

func queue_redraw_if_temperature_bucket_changed() -> void:
	var draw_temp_bucket: int = int(clampf(self.temp, 0, 100))
	if draw_temp_bucket != last_draw_temp_bucket:
		last_draw_temp_bucket = draw_temp_bucket
		queue_redraw()

func on_entered_area(body: Node2D) -> void:
	if body is Neutron:
		set_temperature(self.temp + 5)
		if self.temp < 100:
			if randf() < water_absorb_chance:
				body.kill_self_deflate()
			# let water moderate
			if Neutron.enable_moderation and body.is_fast:
				body.current_speed *= moderation_strength
				body.current_velocity = body.current_velocity.normalized() * body.current_speed
				# stop collidng width moderator:
				if body.current_speed < 100:
					body.is_fast = false
				body.queue_redraw()
