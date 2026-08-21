class_name World
extends Node3D

@export var house: StaticBody3D
@export var player : PackedScene
@export var enemy_spawn: Marker3D
@export var enemy_scene : PackedScene
@export var death_sound: AudioStreamPlayer
@export var enemy_spawn_timer: Timer
@export var round_timer: Timer
@export var round_label: Label
@export var ui_scene: PackedScene
@export var player_spawn: Marker3D
@export var npc_spawn: Marker3D

var door_HP = 100.0
var update_timer = 0.0
var enemy_spawn_range = Vector2(10, 0)
var enemy_spawn_time = 5.0
var enemy_count = 5
var enemy_speed = 5
@export var round_num = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not multiplayer.is_server():
		return
	var new_player : Player = player.instantiate()
	new_player.is_playable = true
	new_player.melee_weapon.hide()
	add_child(new_player)
	new_player.global_position = player_spawn.position
	
	if StoryManager.current_scene == StoryManager.Scene.TWO:
		var npc : Player = player.instantiate()
		npc.is_playable = false
		add_child(npc)
		npc.global_position = npc_spawn.position
		
	elif StoryManager.current_scene == StoryManager.Scene.THREE:
		var npc : Player = player.instantiate()
		npc.is_playable = false
		add_child(npc)
		npc.global_position = npc_spawn.position
		
		var npc2 : Player = player.instantiate()
		npc2.is_playable = false
		add_child(npc2)
		npc2.global_position = npc_spawn.position + Vector3(5, 0, 5)
	
	if not new_player.is_playable:
		$Camera3D.make_current()
	
	update_round()
	_on_enemy_spawn_timer_timeout()
	round_timer.start()


func _on_enemy_death():
	death_sound.play()


func _spawn_enemy():
	var new_enemy : Enemy = enemy_scene.instantiate()
	new_enemy.enemy_died.connect(_on_enemy_death)
	new_enemy.set_speed(enemy_speed)
	new_enemy.position = _get_spawn_position()
	add_child(new_enemy)


func _get_spawn_position():
	var pos = enemy_spawn.global_position
	var srange = enemy_spawn_range
	var rand_x = randi_range(pos.x - srange.x, pos.x + srange.x)
	var rand_z = randi_range(pos.z, pos.z + srange.y)
	
	pos.x = rand_x
	pos.z = rand_z
	return pos

var enemies_close = 0
var enemy_damage = 2

var last_round_timer = 0.0
var win = 3.0
func _physics_process(delta: float) -> void:
	update_timer += delta
	if update_timer >= 0.3:  # update 5x/sec instead of 60x/sec
		update_timer = 0.0
		get_tree().call_group("Enemies", "update_target_location", door_area.global_transform.origin)
		
	if enemies_close > 0:
		door_HP -= delta * enemies_close * enemy_damage
		door_health.value = door_HP
		
		enemies_close = 0
		for body in door_area.get_overlapping_bodies():
			if body is Enemy:
				enemies_close += 1
	
	
	if StoryManager.current_scene == StoryManager.Scene.THREE and round_num > 6:
		last_round_timer += delta
	if last_round_timer >= win:
		StoryManager.update_scene(StoryManager.Scene.FOUR)
		get_tree().change_scene_to_packed(ui_scene)
	
	if door_HP <= 0:
		if StoryManager.current_scene == StoryManager.Scene.ONE:
			StoryManager.update_scene(StoryManager.Scene.FOUR)
			get_tree().change_scene_to_packed(ui_scene)
		else:
			StoryManager.update_scene(StoryManager.Scene.THREE)
			get_tree().change_scene_to_packed(ui_scene)


func _on_enemy_spawn_timer_timeout() -> void:
	if round_num > 5:
		round_num += 1
	if round_num > 8:
		enemy_spawn_timer.stop()
		return
	enemy_spawn_timer.start(enemy_spawn_time)
	for i in enemy_count:
		_spawn_enemy()

@export var new_round_label: Label

@export var door_area: Area3D
@export var door_health: ProgressBar

func _on_round_timer_timeout() -> void:
	round_num += 1
	new_round_label.show()
	
	enemy_spawn_timer.stop()
	round_timer.stop()
	
	var tween = create_tween().set_loops(5)
	tween.tween_property(new_round_label, "modulate:a", 0.3, 0.5)
	tween.tween_property(new_round_label, "modulate:a", 1.0, 0.5)
	
	await get_tree().create_timer(5.0).timeout
	
	new_round_label.hide()
	round_timer.start()
	
	update_round()
	_on_enemy_spawn_timer_timeout()
	enemy_spawn_timer.start(enemy_spawn_time)


func update_round():
	round_label.text = "Round: %d" % round_num
	
	if round_num == 1:
		enemy_spawn_range = Vector2(20, 0)
		enemy_count = 5
		enemy_spawn_time = 5
		enemy_speed = 1
		
	elif round_num == 2:
		enemy_spawn_range = Vector2(12, 3)
		enemy_count = 4
		enemy_spawn_time = 4
		enemy_speed = 5
		
	elif round_num == 3:
		enemy_spawn_range = Vector2(15, 5)
		enemy_count = 3
		enemy_spawn_time = 3
		enemy_speed = 6
		
	elif round_num == 4:
		enemy_spawn_range = Vector2(15, 10)
		enemy_count = 3
		enemy_spawn_time = 3
		enemy_speed = 7.5
		
	elif round_num == 5:
		enemy_spawn_range = Vector2(20, 15)
		enemy_count = 2
		enemy_spawn_time = 1
		enemy_speed = 10
		new_round_label.text = "FINAL ROUND"
		
	else:
		round_label.text = "FINAL ROUND"
		enemy_spawn_range = Vector2(20, 15)
		enemy_count = 25
		enemy_spawn_time = 1
		enemy_speed = 10
		round_timer.stop()


func _on_door_area_body_entered(body: Node3D) -> void:
	if body is Enemy:
		print("HIT DOOR")
		enemies_close += 1


func _on_door_area_body_exited(body: Node3D) -> void:
	if body is Enemy:
		print("Phew...")
		enemies_close -= 1
