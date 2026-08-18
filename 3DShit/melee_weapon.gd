extends Node3D

@export var area_3d: Area3D
var cooldown = 0.2
var timer = cooldown

var enemy_close = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	var enemies = area_3d.get_overlapping_bodies()
	
	timer += delta
	for enemy in enemies:
		if enemy is Enemy and is_instance_valid(enemy) and timer > cooldown:
			enemy.hit()
			print("Hit Enemy")
			timer = 0.0
			return # This prevents area damage
		
		# For loop ran and did not find enemies


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Enemy:
		enemy_close = true
		print("Enemy close")
