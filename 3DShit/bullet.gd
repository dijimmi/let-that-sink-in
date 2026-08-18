class_name Bullet
extends Node3D

@export var mesh: MeshInstance3D
@export var ray: RayCast3D
@export var explosion: GPUParticles3D
@export var collision: CollisionShape3D
@export var shooting_sound: AudioStreamPlayer

const SPEED : float = 40.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shooting_sound.play(0.05)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		if ray.get_collider().is_in_group("Enemies"):
			ray.get_collider().hit()
		ray.enabled = false
		mesh.visible = false
		explosion.emitting = true
		await get_tree().create_timer(explosion.lifetime).timeout
		queue_free()


func _on_lifetime_timeout() -> void:
	queue_free()
