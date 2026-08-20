extends Node
## Handles and abstractizes the methods from InkGD.
##
## I compacted some of the most used methods from [member _ink_player] so that it's easier
## for a non-Ink user to understand better how they work. [br]
##  [br]
## This script handles ONLY Ink logic and its files, meaning it does not handle where 
## you put the text or the choice buttons.[br]
##  [br]
## To handle that, you must connect your story text (e.g. the Label
## in your textbox) to the signal [signal next_line_reached] which emits a Dictionary
## with the current parsing method.[br]
##  [br]
## [b]Current Parsing Method[/b] (check [method _get_parsed_line] for more details)[br]
## Example line on Ink:[br]
## Emma: Hello, everyone![br]
## [codeblock]
## var parsed_line : Dictionary = {
## 	"character" : "Emma",
## 	"message" : "Hello, everyone!"
## }
## [/codeblock]

## Handles all the methods available from inkgd to read and parse story text from .ink files
## and take them into Godot.
@onready var _ink_player : InkPlayer = InkPlayer.new()

## Path for the story file already compiled into '.json' format.
const _ink_file_json : String = "res://InkFiles/story.ink.json"

## MUST be connected to the method in your [TestingVN] that handles how choices are portrayed in
## a story. This signal is emitted when [method continue_story] detects that there are choices to be made.
## It emits an [Array] of choices (I believe to be [String]) which you can handle in your story your own
## way.
signal choices_reached(choices : Array)

## MUST be connected to the method in your [TestingVN] that handles the story text. This signal is emitted 
## when [method continue_story] detects a new link in the story.
## It emits a [Dictionary] with the name of the character speaking, and the line of text
signal next_line_reached(line_elements : Dictionary)

## Stores the functions that are going to be binded from ink.
var _to_bind : Array[Dictionary] = [

]
## If the story is loaded succesfully this will signal the ink player of it.
func _story_loaded(successfully: bool) -> void:
	if !successfully:
		print("Story was NOT loaded.")
		return
	
	_bind_all()
	jump_to_path(StoryManager.get_current_path())
	continue_story()

## Binds all the methods stored in [member _to_bind]
func _bind_all() -> void:
	for binded in _to_bind:
		_ink_player.bind_external_function(binded["ink"], binded['node'], binded['gd'])

## Returns a dictionary containing the elements of a line, such as character name
## and its message. [b]Change this to support expressions[/b]
func _get_parsed_line() -> StoryMessage:
	var text = _ink_player.continue_story()
	var elements = []
	var parsed_line : StoryMessage = StoryMessage.new()
	
	# Parsing method
	if text.contains(":"):
		elements = text.split(":")
	else:
		elements.append("")
		elements.append(text)
		
	parsed_line.character = elements[0]
	parsed_line.message = elements[1]
	
	return parsed_line

## Initializes the story and adds the [member _ink_player] to the [param story_node] given.
## If you have external functions that need to be binded, this method needs to be called
## AFTER calling [method bind_to_ink] or else it will crash.
func init_story(story_node : Control) -> void:
	# Adds the Ink Player as a child and loads the story
	story_node.add_child(_ink_player)
	_ink_player.ink_file = load(_ink_file_json)
	print("Ink file cargado: ", _ink_player.ink_file)
	_ink_player.loads_in_background = false # VERY IMPORTANT - IT ALLOWS WEB EXPORT

	_ink_player.connect("loaded", Callable(self, "_story_loaded"))
	_ink_player.create_story()


## Adds the [param gd_method] given to be binded with the ink method given in
## [param ink_function] from the script given in [param origin_script].
## MUST be called before [method init_story] or else it will crash.
func bind_to_ink(ink_function : String, gd_method : Callable, origin_script : Object) -> void:
	var method : String = gd_method.get_method()
	var binded : Dictionary = {
		"ink" : "method",
		"gd" : "method",
		"node" : "node"
	}
	binded["ink"] = ink_function
	binded['gd'] = method
	binded["node"] = origin_script
	_to_bind.append(binded)


## Continues the story where it last left off. If the next line is a text, it will
## emit the [signal next_line_reached]. If the next line is a choice, it will emit
## the [signal choices_reached] signal.
func continue_story() -> void:
	# If the story has more dialogue, it will continue
	if _ink_player.can_continue:
		next_line_reached.emit(_get_parsed_line())
	# If the story has a choice, it will add those choices to the
	# to the options menu
	elif _ink_player.has_choices:
		# 'current_choices' contains a list of the choices, as strings.
		choices_reached.emit(_ink_player.current_choices)
	else:
		# This code runs when the story reaches it's end.
		print("The End")


## Selects the choice associated with the given [param choice_index] and continues
## the story. The [param choice_index] but correlate with the order in which the
## choices were received when [signal choices_reached] was emitted.
func select_choice(choice_index : int) -> void:
	_ink_player.choose_choice_index(choice_index)
	continue_story()


## Resets the story back to its starting point.
func reset_story() -> void:
	_ink_player.reset()


## Jumps to the given [param path_name] in the story. This [param path_name] MUST
## be the name of a knot in the story '.ink' file, or else it will fail. [br]
## @experimental
## [b]Marked as experimental because I've run into issues with this before, though
## I think it works this way. Just keep it in mind. [/b]
func jump_to_path(path_name : String) -> void:
	_ink_player.choose_path(path_name)

## CURRENTLY NOT BEING USED
## @experimental
func load_json(file_path : String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data


func _observe_variables(variables_list):
	_ink_player.observe_variables(variables_list, self, "_variable_changed")


func _variable_changed(variable_name, new_value):
	print("Variable {var} changed to {val}".format({"var": variable_name, "val" : new_value}))


func set_variable(variable_name, new_value):
	_ink_player.set_variable(variable_name, new_value)


func get_variable(variable_name):
	return _ink_player.get_variable(variable_name)
