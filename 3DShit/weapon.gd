class_name Weapon
extends Node3D

@export var muzzle: Marker3D
@export var bullet : PackedScene
@export var valve_timer: Timer
var bullet_reload_time = 1.0
var valve_active = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var tween : Tween

func shoot(world : World):
	
	if tween and tween.is_valid():
		tween.kill()
	
	var rot = rotation.z
	var dur = 0.1
	if valve_active:
		dur = bullet_reload_time / 2
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "rotation:z", rot + 0.2, dur - 0.02)
	tween.tween_property(self, "rotation:z", rot, dur)
	
	
	var bullet_inst : Bullet = bullet.instantiate()
	bullet_inst.setup(valve_active)
	if valve_active:
		bullet_reload_time = 0.1
		if valve_timer.is_stopped():
			valve_timer.start()
	else:
		bullet_reload_time = 1.0
		
	world.add_child(bullet_inst)
	bullet_inst.position = global_transform.origin
	bullet_inst.global_transform.origin = muzzle.global_transform.origin
	bullet_inst.global_transform.basis = get_parent().global_transform.basis


func _on_valve_timer_timeout() -> void:
	valve_timer.stop()
	valve_active = false
