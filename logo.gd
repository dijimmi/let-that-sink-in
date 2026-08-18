extends Control

@export var do: Label
@export var not_: Label
@export var title: Label
@export var do_not_sound: AudioStreamPlayer
@export var zoom_in: AudioStreamPlayer

signal logo_anim_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animate_do()


func animate_do():
	var tween = create_tween()
	var target_pos = Vector2(0, 0)
	var init_pos = Vector2(-700, 15)
	var duration = 0.7
	
	tween.tween_property(do, "position", init_pos, 0)
	tween.tween_property(do, "scale", Vector2(10, 10), 0)
	
	tween.tween_property(do, "position", target_pos, duration)
	tween.parallel().tween_property(do, "scale", Vector2(1, 1), duration)
	tween.parallel().tween_property(do, "rotation_degrees", 5.0, duration)
	tween.parallel().tween_callback(zoom_in.play)
	
	tween.tween_callback(do_not_sound.play)
	
	target_pos = Vector2(453, 5)
	
	tween.tween_property(not_, "position", init_pos, 0)
	tween.tween_property(not_, "scale", Vector2(10, 10), 0)
	
	tween.tween_property(not_, "position", target_pos, duration)
	tween.parallel().tween_property(not_, "scale", Vector2(1, 1), duration)
	tween.parallel().tween_property(not_, "rotation_degrees", -5.0, duration)
	tween.parallel().tween_callback(zoom_in.play)
	
	tween.tween_callback(do_not_sound.play)
	
	await tween.finished
	logo_anim_over.emit()
