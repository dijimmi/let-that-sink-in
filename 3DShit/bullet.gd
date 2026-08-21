class_name Bullet
extends CharacterBody3D

@export var mesh: MeshInstance3D
@export var collision_shape : CollisionShape3D
@export var explosion: GPUParticles3D
@export var shooting_sound: AudioStreamPlayer
@export var area_3d: Area3D
@export var lifetime: Timer
@export var mini_area: Area3D
@export var red_valve: MeshInstance3D

var SPEED : float = 100.0
var hit_count = 0
var ricochet = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shooting_sound.play(0.05)


func setup(valve : bool):
	if valve:
		ricochet = true
		SPEED = 50.0
		red_valve.show()
		mesh.hide()
	else:
		ricochet = false
		SPEED = 100.0
		red_valve.hide()
		mesh.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	var direction
	var pos_delta
	if hit_count > 0 and ricochet and is_instance_valid(current_target):
		direction = (current_target.global_position - global_position).normalized()
		direction.y = 0.0
		pos_delta = direction * SPEED * delta
		#print("Richocheting to: ", current_target.global_position)
	else:
		direction = global_transform.basis
		pos_delta = direction * Vector3(0, 0, -SPEED) * delta
	
	var collision : KinematicCollision3D = move_and_collide(pos_delta)
	
	for b in mini_area.get_overlapping_bodies():
		if b == current_target:
			collision_shape.set_deferred("disabled", false)
			break
	
	if collision:
		var collider = collision.get_collider()
		if collider is Enemy:
			collision_shape.disabled = not ricochet
			if collider.hit(self):
				hit_count += 1
				if ricochet:
					if hit_count == 1:
						target_list.append(collider)
					lifetime.start(5)
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
	var last_target = current_target
	for body in bodies:
		if body == current_target:
			continue
		if body.is_in_group("Enemies") and not body in target_list:
			current_target = body
			target_list.append(body)
			print("NEW TARGET")
			print(target_list)
			return
	
	if last_target == current_target:
		print("stayed the same")
		current_target = null


func _on_lifetime_timeout() -> void:
	queue_free()
