class_name StoryText
extends RichTextLabel

var visible_char = 0
var text_speed = 50
var animation_enabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_speed(val):
	text_speed = val

func get_speed():
	return text_speed

func toggle_text_animation():
	animation_enabled = not animation_enabled
	visible_char = -1
	visible_characters = -1

func setup(story_text : String) -> void:
	if animation_enabled:
		visible_characters = 0
		visible_char = 0
	else:
		visible_char = -1
		visible_characters = -1
	text = story_text

func show_full_text() -> void:
	visible_char = text.length()
	visible_characters = visible_char

func get_curr_text():
	return text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (visible_char < text.length() or visible_char == -1) and animation_enabled:
		visible_char += text_speed * delta
		visible_characters = visible_char
