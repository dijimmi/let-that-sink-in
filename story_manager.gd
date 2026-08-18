extends Node

enum Scene { ONE, TWO }

var current_scene = Scene.ONE

var paths : Dictionary[Scene, String] = {
	Scene.ONE : "start",
	Scene.TWO : "homeless_scene"
}

func update_scene(new_scene : Scene):
	current_scene = new_scene

func get_current_path() -> String:
	return paths.get(current_scene, "error")
	
