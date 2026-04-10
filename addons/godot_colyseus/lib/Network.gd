extends Node

# 1. Preload the Colyseus library
const Colyseus = preload("res://addons/godot_colyseus/lib/colyseus.gd")

# 2. Preload YOUR generated schema file
const MyRoomState = preload("res://MyRoomState.gd") 

var client
var room

func _ready():
	await get_tree().process_frame
	print("Network: Initializing...")
	
	# Instantiate the Client
	client = Colyseus.Client.new("ws://localhost:2567")
	
	_connect_to_game()

func _connect_to_game():
	print("Network: Attempting connection...")

	# Execute the matchmaker request
	var promise = client.join_or_create(MyRoomState, "my_room", {})
	
	var result = await promise.completed
	
	# --- ENHANCED SAFETY CHECK ---
	if result == null:
		if promise.has_method("get_error") and promise.get_error() != null:
			printerr("Network Error Details: ", promise.get_error())
		else:
			printerr("Network: Join failed! Result is Nil. Is your Node.js server running?")
		return
		
	if result is int:
		printerr("Network: Join failed! Error code: ", result)
		return
	# -----------------------------
	
	# Success!
	room = result
	_on_joined()

func _on_joined():
	print("Network: Connected successfully!")
	print("Network: Session ID: ", room.session_id)
	
	# Register listeners for server messages
	room.on_message("hello", func(msg):
		print("Server says: ", msg)
	)

func _exit_tree():
	if room != null:
		room.leave()
		print("Network: Left the room.")
