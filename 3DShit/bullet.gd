class_name Bullet
extends CharacterBody3D

@export var mesh: MeshInstance3D
@export var collision_shape : CollisionShape3D
@export var explosion: GPUParticles3D
@export var shooting_sound: AudioStreamPlayer
@export var area_3d: Area3D
@export var lifetime: Timer
@export var mini_area: Area3D

const SPEED : float = 10.0
var hit_count = 0
var ricochet = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shooting_sound.play(0.05)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	var direction
	var pos_delta
	if hit_count > 0 and ricochet and is_instance_valid(current_target):
		direction = (current_target.global_position - global_position).normalized()
		pos_delta = direction * SPEED * delta
		print("Richocheting to: ", current_target.global_position)
	else:
		direction = global_transform.basis
		pos_delta = direction * Vector3(0, 0, -SPEED) * delta
	
	if mini_area.get_overlapping_bodies().is_empty():
		collision_shape.disabled = false
	
	var collision : KinematicCollision3D = move_and_collide(pos_delta)
	
	if collision:
		var collider = collision.get_collider()
		if collider is Enemy:
			collision_shape.disabled = not ricochet
			if collider.hit(self):
				hit_count += 1
				if ricochet:
					lifetime.start()
					update_target()
				
					if hit_count < 5:
						return
					
				mesh.visible = false
				explosion.emitting = true
				await get_tree().create_timer(explosion.lifetime).timeout
				queue_free()
				
			else:
				collision_shape.disabled = true
				
var current_target = null
var target_list = []

func update_target():
	var bodies = area_3d.get_overlapping_bodies()
	for body in bodies:
		if body == current_target:
			continue
		if body is Enemy and not body in target_list:
			current_target = body
			target_list.append(body)
			break


func _on_lifetime_timeout() -> void:
	queue_free()
