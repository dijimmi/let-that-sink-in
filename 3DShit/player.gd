class_name Player
extends CharacterBody3D

var speed = 0.0
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
var bullet_inst : Bullet

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

var bullet_reload_time = 0.1
var t_bullet = bullet_reload_time


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	if not is_multiplayer_authority(): return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	head_camera.current = true


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		head_camera.rotate_x(-event.relative.y * SENSITIVITY)
	if Input.is_action_just_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "front", "back")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		
	t_bob += delta * velocity.length() * float(is_on_floor())
	head_camera.transform.origin = _headbob(t_bob)
	
	if t_bullet >= bullet_reload_time * 2:
		t_bullet = bullet_reload_time
	t_bullet += delta
	if Input.is_action_pressed("shoot") and t_bullet > bullet_reload_time:
		t_bullet = 0.0
		_shoot.rpc()
		
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

@rpc("call_local", "any_peer", "reliable")
func _shoot():
	bullet_inst = bullet.instantiate()
	get_parent().add_child(bullet_inst)
	bullet_inst.position = weapon.global_transform.origin
	bullet_inst.global_transform.origin = weapon.muzzle.global_transform.origin
	bullet_inst.global_transform.basis = head_camera.global_transform.basis
			
