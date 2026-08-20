class_name TestingVN
extends Control

@export_group("Main Nodes")
@export var background_img: TextureRect
@export var textbox: VNTextBox
@export var choices_buttons: HBoxContainer

@export_category("Visual Assets")
@export var characters: Dictionary[String, CharacterInfo]
@export var backgrounds: Dictionary[String, Texture]
var character_sprites: Dictionary[String, CharacterSprite]

@export_category("Misc")
@export_group("Misc")
@export var character_sprite_scene: PackedScene
@export var level1 : String

var curr_player
var choices_added = false

func _ready() -> void:
	InkManager.bind_to_ink("background", EXT_background, self)
	InkManager.bind_to_ink("load_scene", EXT_load_scene, self)
	InkManager.bind_to_ink("speak", EXT_speak, self)
	InkManager.bind_to_ink("move", EXT_move_character, self)
	InkManager.bind_to_ink("show_or_hide", EXT_show_or_hide, self)
	
	InkManager.init_story(self)
	
	InkManager.next_line_reached.connect(_on_next_line_reached)
	InkManager.choices_reached.connect(_on_choices_reached)
	textbox.continued_story.connect(_on_button_pressed)
	
	_add_all_characters()


func _add_all_characters():
	for char_info in characters.values():
		var ch: CharacterSprite = character_sprite_scene.instantiate()
		ch.setup(char_info)
		ch.hide()
		character_sprites[char_info.my_name] = ch
		background_img.add_sibling(ch)


func _on_next_line_reached(parsed_text : StoryMessage):
	textbox.setup(parsed_text.character, parsed_text.message)


func _on_choices_reached(choices):
	if not choices_added:
		for i in choices.size():
			var btn = Button.new()
			btn.size = Vector2(500, 500)
			btn.text = str(i) + choices[i].text
			btn.pressed.connect(select_choice.bind(btn))
			choices_buttons.add_child.call_deferred(btn)
		choices_added = true


func select_choice(button : Button):
	choices_added = false
	var index = int(button.text.substr(0,1))
	
	for child in choices_buttons.get_children():
		child.queue_free()
	
	InkManager.select_choice(index)


func _spell_check(entered_text : String, target_text : String, acceptable_range : float = 0.7):
	var correct_letters : int = 0
	var word_size : int
	entered_text = entered_text.to_lower()
	target_text = target_text.to_lower()
	
	if entered_text == target_text:
		print("No Spelling Mistake, Yippie!")
		return target_text
	
	if entered_text.length() == target_text.length():
		correct_letters += 1
	
	if entered_text.length() < target_text.length():
		word_size = entered_text.length()
	else:
		word_size = target_text.length()
		
	for i in word_size:
		if entered_text[i] == target_text[i]:
			correct_letters += 1
	
	for j in entered_text.length():
		if entered_text[j] in target_text:
			correct_letters += 1
	
	if correct_letters >= (target_text.length() * 2) * acceptable_range:
		print("Entered Text: %s. Did you mean '%s'?" % [entered_text, target_text])
		push_error("Entered Text: %s. Did you mean '%s'?" % [entered_text, target_text])
		return target_text
	else:
		print("May the lord save you from your sins...")
		return entered_text


func _on_button_pressed() -> void: InkManager.continue_story()

# ==============================================================
# External INK Functions
# ==============================================================


func EXT_show_or_hide(who: String, appear: bool):
	var character: CharacterSprite = character_sprites.get(who)
	if appear:
		character.show()
	else:
		character.hide()


func EXT_move_character(who: String, where: int):
	var character : CharacterSprite = character_sprites[who]
	character.move_to(where)


func EXT_load_scene(scene : String):
	if "level" in scene:
		get_tree().change_scene_to_file(level1)


func EXT_background(key : String):
	var bg = backgrounds.get(key)
	background_img.texture = bg


func EXT_speak(who : String, word : String):
	var character = characters.get(who)
	$Voice.stream = character.get_voiceline(word)
	$Voice.play()
