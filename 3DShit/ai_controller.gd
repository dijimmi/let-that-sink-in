class_name AIController
extends InputController

@export var player: Player
@export var nav: NavigationAgent3D
@export var detection_aura: Area3D

var range = 5
var range_mod = 0.8
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var update_timer = 0.0

func _physics_process(delta: float) -> void:
	if player.is_playable:
		return
	
	if is_instance_valid(current_enemy):
		var target = current_enemy.global_position
		target.y = player.head_camera.global_position.y
		
		var distance = (player.global_position - target).length()
		is_shooting = distance < range
		
		player.head_camera.look_at(target)
	else:
		is_shooting = false
	
	update_timer += delta
	if update_timer >= 0.2:  # update 5x/sec instead of 60x/sec
		update_timer = 0.0
		update_target_location()


func move_camera(event : InputEvent, head : Node3D, head_camera : Camera3D, sensitivity):
	pass

func get_direction(_head) -> Vector3:
	var next_location = nav.get_next_path_position()
	var current_location = player.global_position
	
	var direction = Vector3((next_location.x - current_location.x), 0, (next_location.z - current_location.z)).normalized()
	return direction


func shooting_triggered():
	return is_shooting

var is_shooting = false

var current_enemy : Enemy = null

func update_target_location():
	var enemies_in_range = detection_aura.get_overlapping_bodies()
	var target
	
	if current_enemy == null or not is_instance_valid(current_enemy):
		for enemy in enemies_in_range:
			if enemy is Enemy:
				current_enemy = enemy
				print("Enemy in Range")
				break
		if current_enemy == null:
			return
			
	
	if current_enemy.is_node_ready():
		
		target = current_enemy.global_position
		target = Vector3(target.x, target.y, target.z - range * range_mod)
		target.y = player.global_transform.origin.y
		nav.target_position = target

		print("Target: ", target)
