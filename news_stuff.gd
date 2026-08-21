extends Control

@export var video: VideoStreamPlayer
@export var sink: TextureRect
@export var blush: TextureRect
@export var sink_timer: Timer
@export var news: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS


func show_video():
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween = create_tween()
	var video_pos = Vector2(0, 0)
	var video_size = Vector2(1, 1)
	video.modulate.a = 0.0
	
	tween.tween_callback(video.show)
	tween.tween_callback(video.play)
	tween.tween_callback(func() : news.stream.loop = true)
	tween.tween_callback(news.play)
	tween.tween_property(video, "global_position", video_pos, 1.0)
	tween.parallel().tween_property(video, "scale", video_size, 1.0)
	tween.parallel().tween_property(video, "modulate:a", 1.0, 1.0)
	tween.tween_callback(sink_timer.start)


func _on_sink_timer_timeout() -> void:
	if not sink.visible:
		sink.show()
		sink_timer.start(6)
	elif not blush.visible:
		blush.show()
		sink_timer.start(6)
	else:
		$SinkBaby1.show()
		$SinkBaby2.show()
		sink_timer.stop()


func _on_video_finished() -> void:
	queue_free()
	get_parent().get_node("TextBox").show()
