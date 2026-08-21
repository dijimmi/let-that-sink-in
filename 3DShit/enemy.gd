class_name Enemy
extends CharacterBody3D
@export var nav_agent : NavigationAgent3D
var SPEED = 0.0
@export var label: Label3D
@export var animated_sprite_3d: AnimatedSprite3D

static var count = 0
signal enemy_died
var hit_counter = 0
var health = 2
var unique_bullet : Bullet = null

func _ready():
	count += 1
	label.text += str(health - hit_counter)

func set_speed(new_speed):
	SPEED = new_speed

## Pass bullet only if ricochet. Returns true if hit was successful, false if not.
func hit(bullet : Bullet = null) -> bool:
	if bullet == unique_bullet:
		return false
	
	print("Ow, that hurt :(")
	hit_counter += 1
	label.text = "Hits Left: " + str(health - hit_counter)
	
	if is_instance_valid(bullet):
		unique_bullet = bullet
	
	if hit_counter >= 2:
		enemy_died.emit()
		queue_free()
	
	return true


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	
	#var my_pos = global_position
	#if is_instance_valid(unique_bullet):
		#var last_bullet_loc = unique_bullet.global_position
		#last_bullet_loc.y = 0.0
		#my_pos.y = 0.0
		#var distance = my_pos.distance_to(last_bullet_loc)
		#print("OOOH THTE DISTANCE: ", distance)
		#if distance > 1.5:
			#unique_bullet.collision_shape.set_deferred("disabed", false)
			#unique_bullet = null
	
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
