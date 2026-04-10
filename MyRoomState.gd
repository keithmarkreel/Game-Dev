extends "res://addons/godot_colyseus/lib/schema.gd"

const PlayerSchema = preload("res://scripts/PlayerSchema.gd")

static func define_fields():
	return [
		Field.new("players", Types.MAP, PlayerSchema),
	]
