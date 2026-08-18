extends Control

@export var texture_rect: TextureRect
@export var logo: Control
@export var menu_music: AudioStreamPlayer
@export var blush: TextureRect
@export var blush_sound_effect: AudioStreamPlayer

var sink_animation_enabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if StoryManager.current_scene == StoryManager.Scene.TWO:
		process_mode = Node.PROCESS_MODE_DISABLED
	logo.logo_anim_over.connect(_enable_sink_animation)

@onready var base = texture_rect.position
var t = 0.0
var freq = 3.5
@export var play: Button

func _enable_sink_animation():
	
	blush.visible = true
	blush_sound_effect.play()
	
	await blush_sound_effect.finished
	
	sink_animation_enabled = true
	menu_music.play()
	play.disabled = false


func _process(delta):
	
	if sink_animation_enabled:
		t += delta
		animate_sink()


func animate_sink():
	texture_rect.position.x = base.x + sin(t * freq) * 30
	texture_rect.position.y = base.y + sin(t * freq * 2) * 10
	texture_rect.rotation_degrees = sin(t * freq) * 2.5
