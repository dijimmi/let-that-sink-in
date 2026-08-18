class_name Enemy
extends CharacterBody3D
@export var nav_agent : NavigationAgent3D
const SPEED = 5.0
@export var label: Label3D

static var count = 0
signal enemy_died
var dead = false

func _ready():
	count += 1
	label.text += str(count)

func hit():
	print("Ow, that hurt :(")
	if not multiplayer.is_server():
		return
	if not dead:
		dead = true
		enemy_died.emit()		
		queue_free()

func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
		
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	
	var direction = (next_location - current_location)
	direction.y = 0.0
	
	if direction.length() < 0.2:
		velocity.x = 0
		velocity.z = 0
	else:
		direction = direction.normalized()
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	
	move_and_slide()


func update_target_location(target):
	target.y = global_transform.origin.y
	nav_agent.target_position = target
