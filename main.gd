extends Node

@export var vn: VisualNovel
@export var main_menu: CanvasLayer
@export var player : PackedScene

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
@export var world : World

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("OUI, we make games")
	print("args: ", OS.get_cmdline_args())
	print("user args: ", OS.get_cmdline_user_args())
	if OS.has_feature("dedicated_server") or "--server" in OS.get_cmdline_user_args():
		_start_dedicated_server()

func _start_dedicated_server() -> void:
	main_menu.hide()
	
	var port = PORT
	var env_port = OS.get_environment("PORT")
	if env_port != "":
		port = int(env_port)
	
	var err = enet_peer.create_server(port)
	if err != OK:
		print("Error creando servidor: ", err)
		get_tree().quit(1)
		return
	
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	print("Servidor dedicado escuchando en puerto ", port)

func _on_host_pressed() -> void:
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

	add_player(multiplayer.get_unique_id())

func _on_join_pressed() -> void:
	main_menu.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var new_player : Player = player.instantiate()
	new_player.name = str(peer_id)
	world.add_child(new_player)

func remove_player(peer_id):
	var old_player = world.get_node_or_null(str(peer_id))
	if old_player:
		old_player.queue_free()
