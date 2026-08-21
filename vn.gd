class_name VisualNovel
extends Control

@onready var _ink_player = InkPlayer.new()
@export var ink_file : String
@export var story_test: StoryText
@export var choices_buttons: HBoxContainer
@export var character_name: Label
@export var background_img: TextureRect
@onready var node: Node = get_parent()

@export var main : PackedScene

@export var level1 : String

var curr_player

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	#await node.start_game
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_ink_player)
	_init_story()
	
# TODO: This function might cause problems because it's called twice on start.
# It's called in _ready() and it's also called by 'main.gd' when the play button
# is pressed though I don't remember why I made it so it was called there.
func _init_story():
	# Adds the Ink Player as a child and loads the story
	_ink_player.ink_file = load("res://InkFiles/story.ink.json")
	print("Ink file cargado: ", _ink_player.ink_file)
	_ink_player.loads_in_background = false # VERY IMPORTANT - IT ALLOWS WEB EXPORT

	_ink_player.connect("loaded", Callable(self, "_story_loaded"))
	_ink_player.create_story()

	_connect_signals()


# If the story is loaded succesfully this will signal the ink player of it.
func _story_loaded(successfully: bool):
	if !successfully:
		print("Story was NOT loaded.")
		return

	_bind_to_ink()
	
	jump_to_path(StoryManager.get_current_path())
	
	continue_story()


func _connect_signals():
	pass


func _bind_to_ink():
	_ink_player.bind_external_function("background", self, "background")
	_ink_player.bind_external_function("load_scene", self, "load_scene")	

var choices_added = false
## This function will be called when the story is going to continue,
## be it in a loop or in a recursion. In this case my clicks
func continue_story():
	# If the story has more dialogue, it will continue
	if _ink_player.can_continue:
		var text = _ink_player.continue_story()
		if text.contains(":"):
			var elements = text.split(":")
			curr_player = elements[0]
			text = elements[1]
		
		if curr_player == "Narrator":
			character_name.text = ""
		else:
			character_name.text = curr_player
		story_test.setup(text)
	# If the story has a choice, it will add those choices to the
	# to the options menu
	elif _ink_player.has_choices:
		# 'current_choices' contains a list of the choices, as strings.
		var choices = _ink_player.current_choices
		if not choices_added:
			for i in choices.size():
				var btn = Button.new()
				btn.size = Vector2(500, 500)
				btn.text = str(i) + choices[i].text
				btn.pressed.connect(select_choice.bind(btn))
				choices_buttons.add_child.call_deferred(btn)
			choices_added = true
	else:
		# This code runs when the story reaches it's end.
		print("The End")


func select_choice(button : Button):
	choices_added = false
	var index = int(button.text.substr(0,1))
	
	for child in choices_buttons.get_children():
		child.queue_free()
	
	_ink_player.choose_choice_index(index)
	continue_story()


func load_scene(scene : String):
	if "level" in scene:
		get_tree().change_scene_to_file(level1)
	elif "menu" in scene:
		get_parent().reset()


func background(key : String):
	if "gun" in key:
		background_img.texture = load("uid://cjryq86v83h24")
	elif "black" in key:
		background_img.hide()
		$SFX.play(0.05)


## CURRENTLY NOT BEING USED
func manage_story_state(person_name : String) -> void:
	var curr_state = 'chats_states.get(person_name)'

	# If this chat has not been accessed before and/or its state has not been saved, then
	# we will jump to the knot in the beginning of that chat.
	if curr_state == null:
		print("State not found.")
		_ink_player.choose_path(person_name + "_chat")

	# If this chat has been saved before, then it will load the last state it had.
	else:
		print("State loaded")
		_ink_player.set_state(curr_state)

	continue_story()

# CURRENTLY NOT BEING USED
func load_json(file_path : String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data


func reset_story():
	_ink_player.reset()


func jump_to_path(path_name):
	_ink_player.choose_path(path_name)


func _observe_variables(variables_list):
	_ink_player.observe_variables(variables_list, self, "_variable_changed")


func _variable_changed(variable_name, new_value):
	print("Variable {var} changed to {val}".format({"var": variable_name, "val" : new_value}))


func set_variable(variable_name, new_value):
	_ink_player.set_variable(variable_name, new_value)


func get_variable(variable_name):
	return _ink_player.get_variable(variable_name)


func _on_button_pressed() -> void:
	continue_story()
