extends "res://addons/godot_colyseus/lib/schema.gd"

static func define_fields():
	return [
		Field.new("sessionId", Types.STRING),
		Field.new("x", Types.NUMBER),
		Field.new("y", Types.NUMBER),
	]
