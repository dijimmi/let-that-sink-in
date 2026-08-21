class_name Player
extends CharacterBody3D

var speed = 6.7
const SPRINT_SPEED = 20.0
const WALK_SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export_category("Head")
@export var head: Node3D
@export var head_camera: Camera3D

@export_category("Camera Settings")
@export var SENSITIVITY : float = 0.003

@export_category("Weapons")
@export var weapon : Weapon
@export var bullet : PackedScene
@export var melee_weapon: Node3D
var bullet_inst : Bullet

@export_category("Appareance")
@export var mesh : MeshInstance3D

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

## includes the time that the ability is active
var valve_cooldown = 10.0
var t_valve = valve_cooldown
@onready var t_bullet = weapon.bullet_reload_time

var is_playable = null

@export var input_controller: InputController
@export var ai_controller: Node3D

var controller : InputController

func _enter_tree() -> void:
	pass
	#set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if not is_multiplayer_authority(): return
	assert(is_playable != null, "Player property 'is playable' is null")
	
	if is_playable:
		controller = input_controller
		head_camera.current = true
		%Front.hide()
		%Back.hide()
	else:
		controller = ai_controller
		#var new_material = StandardMaterial3D.new() 
		#new_material.albedo_color = Color(1.0, 0.0, 0.0, 1.0) # Red
		#mesh.material_override = new_material
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	controller.move_camera(event, head, head_camera, SENSITIVITY)
	
	if Input.is_action_just_pressed("esc") and is_playable:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("ui_right") and is_playable:
		if t_valve <= valve_cooldown:
			print('nuh uh')
		else:
			weapon.valve_active = true
			t_valve = 0.0


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction := controller.get_direction(head)
		
	_move(direction, delta)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	head_camera.transform.origin = _headbob(t_bob)
	
	if t_bullet >= weapon.bullet_reload_time * 2:
		t_bullet = weapon.bullet_reload_time
	t_bullet += delta
	
	if t_valve >= valve_cooldown * 2:
		t_valve = valve_cooldown
	t_valve += delta
	
	if controller.shooting_triggered() and t_bullet > weapon.bullet_reload_time:
		t_bullet = 0.0
		_shoot.rpc()
		
	move_and_slide()


func _move(direction, delta):
	if is_on_floor():
		if direction.length() > 0.2:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			%Front.play("front")
			%Back.play("front")
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

@rpc("call_local", "any_peer", "reliable")
func _shoot():
	weapon.shoot(get_parent())
