extends Node2D

@onready var projectile_caller: ProjectileCaller2D = $ProjectileCaller2D
@onready var parry_cooldown: Timer = $parryCooldown
@onready var parryWall = preload("res://entities/parry_wall.tscn")

var input_vector = null
var record_spell_input = false
var inputs = PackedVector2Array()
var can_parry = true

const parry_distance = 25.0

func _input(event):
	if event is InputEventMouseButton:
		projectile_caller.get_projectile(0).set_on_collision(custom_collision)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			projectile_caller.request_projectile(0, position, get_global_mouse_position())
	# If the joypad is moving, deal with it
	if event is InputEventJoypadMotion:
		handle_joystick_input()

func handle_joystick_input():
	var joy_position: Vector2 = Input.get_vector("parry_left", "parry_right", "parry_up", "parry_down")
	var strength: float = joy_position.length()
	
	if strength > 0.9 and can_parry:
		# Run Parry Event
		parry_cooldown.start()
		can_parry = false
		var parryinstance = parryWall.instantiate()
		add_child(parryinstance)
		parryinstance.position = Vector2(joy_position.x * parry_distance, joy_position.y * parry_distance)
		parryinstance.rotation = joy_position.angle()

# Once parry cooldown is done, reset ability to parry
func _on_parry_cooldown_timeout() -> void:
	can_parry = true
	pass # Replace with function body.

# In this example we set the "custom_collision" function at our projectile with index (0).
func _ready() -> void:
	#projectile_caller.get_projectile(0).set_on_collision(custom_collision)
	pass

# In order to function, your collision method must follow this design pattern.
func custom_collision(proj: Projectile2D, area_rid: RID, area_node: Node2D, target_node: Node2D, area_shape_index: int, local_shape_index: int) -> void:
	if not proj.validate_collision(area_rid, area_node):
		return
	
	var wall_layer: int = proj.global_properties["WALL_LAYER"]
	if wall_layer & area_node.collision_layer != 0:
		proj.is_expired = true
		return

	if target_node.has_method(proj.on_hit_call):
		target_node.call(proj.on_hit_call, proj)
	proj.on_pierced(area_rid)
