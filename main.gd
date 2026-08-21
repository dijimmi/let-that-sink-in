extends Node

@export var vn: VisualNovel
@export var main_menu: CanvasLayer
@export var menu_music: AudioStreamPlayer

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("OUI, we make games")
	process_mode = Node.PROCESS_MODE_DISABLED

	if StoryManager.current_scene != StoryManager.Scene.ONE:
		_on_host_pressed()
	
	process_mode = Node.PROCESS_MODE_ALWAYS


func reset():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu.show()
	menu_music.play()
	vn._ready()


func _on_host_pressed() -> void:
	menu_music.stop()
	main_menu.hide()
	start_game.emit()
