extends Node

const Colyseus = preload("res://addons/godot_colyseus/lib/colyseus.gd")
const MyRoomState = preload("res://MyRoomState.gd")
const PlayerSchema = preload("res://scripts/PlayerSchema.gd")
const LocalPlayerScene = preload("res://Player.tscn")
const RemotePlayerScene = preload("res://RemotePlayer.tscn")

var client
var room
var player_nodes: Dictionary = {}
var local_player: CharacterBody2D = null

func _ready():
	await get_tree().process_frame
	print("Network: Initializing...")
	client = Colyseus.Client.new("ws://localhost:2567")
	_connect_to_game()

func _connect_to_game():
	print("Network: Attempting connection...")
	var promise = client.join_or_create(MyRoomState, "my_room", {})
	await promise.completed
	var result = promise.get_data()
	if result == null or result is int or result is Dictionary:
		printerr("Network: Join failed! ", result)
		return
	room = result
	_on_joined()

func _on_joined():
	print("Network: Connected! Session ID: ", room.session_id)

	room.on_state_change.on(func(state):
		# Spawn new players
		for key in state.players.keys():
			if not player_nodes.has(key):
				var p = state.players.at(key)
				print(">>> Spawning player: ", key)
				if key == room.session_id:
					_spawn_local_player(p, key)
				else:
					_spawn_remote_player(p, key)
		
		# Remove disconnected players
		for key in player_nodes.keys():
			if not state.players.has(key):
				_remove_player(key)
	)

func _spawn_local_player(player, session_id: String):
	local_player = get_tree().current_scene.get_node_or_null("Player")
	if local_player == null:
		local_player = LocalPlayerScene.instantiate()
		local_player.name = session_id
		get_tree().current_scene.add_child(local_player)
	player_nodes[session_id] = local_player
	print("Local player spawned!")

func _spawn_remote_player(player, session_id: String):
	var node = RemotePlayerScene.instantiate()
	node.name = session_id
	node.position = Vector2(player.x, player.y)
	get_tree().current_scene.add_child(node)
	player_nodes[session_id] = node

	# Listen for position changes
	player.listen("x:change").on(func(target, value):
		if is_instance_valid(node):
			node.position.x = player.x
	)
	player.listen("y:change").on(func(target, value):
		if is_instance_valid(node):
			node.position.y = player.y
	)

	print("Remote player spawned at: ", node.position)

func _remove_player(session_id: String):
	if player_nodes.has(session_id):
		player_nodes[session_id].queue_free()
		player_nodes.erase(session_id)

func _process(_delta):
	# Send local player position to server
	if room != null and room.has_joined() and local_player != null:
		room.send("move", {
			"x": local_player.position.x,
			"y": local_player.position.y
		})
	
	# Fallback: sync remote positions every frame directly from state
	if room != null and room.has_joined():
		var state = room.get_state()
		if state != null and state.players != null:
			for key in player_nodes.keys():
				if key != room.session_id:
					var p = state.players.at(key)
					if p != null and is_instance_valid(player_nodes[key]):
						player_nodes[key].position = Vector2(p.x, p.y)

func _exit_tree():
	if room != null:
		room.leave()
		print("Network: Left the room.")
