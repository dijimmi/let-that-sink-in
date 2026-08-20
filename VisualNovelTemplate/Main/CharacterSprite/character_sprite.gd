class_name CharacterSprite
extends Control

enum Positions {LEFTEST, LEFT, CENTER, RIGHT, RIGHTEST}
var positions: Array[Vector2]= [
	Vector2(0,      0),
	Vector2(275.0,  0),
	Vector2(549.0,  0),
	Vector2(834.0,  0),
	Vector2(1098.0, 0),
]

@export var base_sprite: TextureRect
@export var expressions: Control
@export var expression_rect : PackedScene
@export var voice: AudioStreamPlayer

## Use this method after instantiating a [CharacterSprite] scene to setup its textures.[br]
## [br]
## Sets up the base portrait of the given [param character] and its respective expressions
## saved as [Texture] converts them into [TextureRect] and adds them as children.
func setup(character : CharacterInfo):
	base_sprite.texture = character.base_portrait
	for expr in character.expression_portraits.keys():
		var new_exp : TextureRect = expression_rect.instantiate()
		new_exp.texture = character.expression_portraits.get(expr)
		new_exp.name = expr
		expressions.add_child(new_exp)
		new_exp.set_anchors_preset(Control.PRESET_FULL_RECT)
		
	change_expression("Smile")

## Changes the expression of the current character into the new expression given.[br]
## [br]
## [b][color=orange]WARNING:[/color][/b] If no valid expression is given, it will hide all expressions.
func change_expression(new_expression : String):
	for expr : TextureRect in expressions.get_children():
		if expr.name.to_lower() == new_expression.to_lower():
			expr.show()
		else:
			expr.hide()


func move_to(preset : Positions):
	global_position = positions[preset]
