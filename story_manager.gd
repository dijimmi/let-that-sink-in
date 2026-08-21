extends Node

enum Scene { ONE, TWO, THREE, FOUR }

var current_scene = Scene.THREE

var paths : Dictionary[Scene, String] = {
	Scene.ONE : "start",
	Scene.TWO : "homeless_scene",
	Scene.THREE : "retry",
	Scene.FOUR : "finale",
}

func update_scene(new_scene : Scene):
	current_scene = new_scene

func get_current_path() -> String:
	return paths.get(current_scene, "error")
	
