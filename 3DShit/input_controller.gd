class_name InputController
extends Node3D

var head_copy
var head_camera_copy
var sensitivity_copy
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	var look_dir = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	
	if head_copy and head_camera_copy and look_dir != Vector2.ZERO:
		head_copy.rotate_y(-look_dir.x  * delta)
		head_camera_copy.rotate_x(-look_dir.y  * delta)
		head_camera_copy.rotation.x = clamp(head_camera_copy.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		return


func get_direction(head) -> Vector3:
	var input_dir = Input.get_vector("left", "right", "front", "back")
	return (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


func move_camera(event : InputEvent, head, head_camera, sensitivity):
	if DisplayServer.is_touchscreen_available():
		print("MOVED CAMERA")
		head_camera_copy = head_camera
		head_copy = head
		sensitivity_copy = sensitivity
		return
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		head_camera.rotate_x(-event.relative.y * sensitivity)


func shooting_triggered():
	if DisplayServer.is_touchscreen_available():
		#print("You can touch!")
		return Input.is_action_pressed("cam_down") or Input.is_action_pressed("cam_up") or Input.is_action_pressed("cam_left") or Input.is_action_pressed("cam_right")
	return Input.is_action_pressed("shoot")
