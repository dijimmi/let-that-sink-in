class_name CharacterInfo
extends Resource

@export_category("Main")
@export var my_name : String = "Honse"

@export_category("Sprites")
@export var base_portrait : Texture = Texture.new()
@export var expression_portraits : Dictionary[String, Texture]

@export_category("Voicelines")
@export var voicelines : Dictionary[String, AudioStream]

func setup(cname, portrait, expressions):
	my_name = cname
	base_portrait = portrait
	expression_portraits = expressions


func get_voiceline(key : String) -> AudioStream:
	for vl_key in voicelines.keys():
		if vl_key == key:
			return voicelines[vl_key]
	
	push_error("Voiceline with key: %s not found. " % key)
	return AudioStream.new()
