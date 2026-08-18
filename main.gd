extends Node

@export var vn: VisualNovel
@export var main_menu: CanvasLayer

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("OUI, we make games")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if StoryManager.current_scene != StoryManager.Scene.ONE:
		_on_host_pressed()


func _on_host_pressed() -> void:
	main_menu.hide()
	start_game.emit()
