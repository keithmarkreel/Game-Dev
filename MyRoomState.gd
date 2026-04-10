extends "res://addons/godot_colyseus/lib/schema.gd"

const Colyseus = preload("res://addons/godot_colyseus/lib/colyseus.gd")

var mySynchronizedProperty: String = ""

# 1. THE FIX: The SDK looks for 'define_fields', not 'definition'
static func define_fields():
	return [
		Colyseus.Schema.Field.new("mySynchronizedProperty", "string"),
	]

func _to_string() -> String:
	return "MyRoomState(__ref_id: %s, mySynchronizedProperty: %s)" % [self.__ref_id, self.mySynchronizedProperty]
