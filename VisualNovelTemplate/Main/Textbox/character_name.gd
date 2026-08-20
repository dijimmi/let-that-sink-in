class_name CharacterNameLabel
extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(c_name):
	if c_name == "":
		print("Narrator")
		text = "NARRATOR"
	else:
		text = c_name
