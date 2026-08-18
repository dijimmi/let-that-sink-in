class_name World
extends Node3D

@export var house: StaticBody3D
@export var player : PackedScene
@export var enemy_spawn: Marker3D
@export var enemy_scene : PackedScene
@export var death_sound: AudioStreamPlayer

var update_timer = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not multiplayer.is_server():
		return
	_spawn_enemy()
	var new_player = player.instantiate()
	add_child(new_player)


func _on_enemy_death():
	death_sound.play()
	_spawn_enemy()


func _spawn_enemy():
	var new_enemy : Enemy = enemy_scene.instantiate()
	new_enemy.enemy_died.connect(_on_enemy_death)
	
	add_child(new_enemy)
	new_enemy.global_position = _get_spawn_position()


func _get_spawn_position():
	var pos = enemy_spawn.global_position
	var rand = randi_range(pos.x - 10, pos.x + 10)
	
	pos.x = rand
	return pos


func _physics_process(delta: float) -> void:
	update_timer += delta
	if update_timer >= 0.2:  # update 5x/sec instead of 60x/sec
		update_timer = 0.0
		get_tree().call_group("Enemies", "update_target_location", house.global_transform.origin)
