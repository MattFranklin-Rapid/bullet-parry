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
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			projectile_caller.request_projectile(0, position, get_global_mouse_position())

	# If the joypad is moving, deal with it
	if event is InputEventJoypadMotion:
		handle_joystick_input()


func handle_joystick_input():
	var joy_position: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var strength: float = joy_position.length()
	
	if strength > 0.9 and can_parry:
		# Run Parry Event
		print("Parry!")
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
