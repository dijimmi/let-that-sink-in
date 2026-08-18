class_name InputController
extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func get_direction(head) -> Vector3:
	var input_dir = Input.get_vector("left", "right", "front", "back")
	return (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


func move_camera(event : InputEvent, head, head_camera, sensitivity):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		head_camera.rotate_x(-event.relative.y * sensitivity)


func shooting_triggered():
	return Input.is_action_pressed("shoot")
