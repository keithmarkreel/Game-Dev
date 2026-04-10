extends RefCounted

const Schema = preload("res://addons/godot_colyseus/lib/schema.gd")
const Decoder = preload("res://addons/godot_colyseus/lib/decoder.gd")
const Types = preload("res://addons/godot_colyseus/lib/types.gd")

class Serializer:
	func set_state(decoder):
		pass
	func get_state():
		pass
	func patch(decoder):
		pass
	func teardown():
		pass
	func handshake(decoder):
		pass

class NoneSerializer extends Serializer:
	pass

class ReflectionField extends Schema:
	static func define_fields():
		return [
			Schema.Field.new("name", Schema.Types.STRING),
			Schema.Field.new("type", Schema.Types.STRING),
			Schema.Field.new("referenced_type", Schema.Types.NUMBER),
		]

	func test(field, reflection: Reflection) -> bool:
		if self.type != field.current_type.to_string() or self.name != field.name:
			printerr("  !! Field mismatch - name: '", field.name, "' vs '", self.name, "' | type: '", field.current_type, "' vs '", self.type, "'")
			return false
		if self.type == Schema.Types.REF:
			var type = reflection.types.at(self.referenced_type)
			return type.test(field.schema_type, reflection)
		return true

class ReflectionType extends Schema:
	static func define_fields():
		return [
			Schema.Field.new("id", Schema.Types.NUMBER),
			Schema.Field.new("extendsId", Schema.Types.NUMBER),
			Schema.Field.new("fields", Schema.Types.ARRAY, ReflectionField),
		]

	func test(schema_type, reflection: Reflection) -> bool:
		if not schema_type is GDScript:
			printerr("  !! schema_type is not a GDScript for type id=", self.id)
			return false
		var fields = schema_type.define_fields()
		var length = fields.size()
		if length != self.fields.size():
			printerr("  !! Field COUNT mismatch for type id=", self.id,
				": server has ", self.fields.size(),
				" fields, GDScript has ", length)
			return false
		for i in range(length):
			var field = self.fields.at(i)
			if not field.test(fields[i], reflection):
				return false
		return true

class Reflection extends Schema:
	static func define_fields():
		return [
			Schema.Field.new("types", Schema.Types.ARRAY, ReflectionType),
			Schema.Field.new("root_type", Schema.Types.NUMBER),
		]

	func test(schema_type: GDScript) -> bool:
		return self.types.at(self.root_type).test(schema_type, self)

class SchemaSerializer extends Serializer:
	var state
	var schema_type: GDScript

	func _init(schema_type):
		self.schema_type = schema_type
		self.state = schema_type.new()

	func handshake(decoder):
		var reflection = Reflection.new()
		reflection.decode(decoder)

		print("=== SERVER REFLECTION ===")
		print("Total types: ", reflection.types.size())
		print("Root type index: ", reflection.root_type)
		for i in range(reflection.types.size()):
			var t = reflection.types.at(i)
			print("Type[", i, "]  id=", t.id, "  field_count=", t.fields.size())
			for j in range(t.fields.size()):
				var f = t.fields.at(j)
				print("    field[", j, "]  name='", f.name, "'  type='", f.type, "'  ref=", f.referenced_type)

		print("=== GDSCRIPT define_fields() ===")
		var gd_fields = schema_type.define_fields()
		print("Total fields: ", gd_fields.size())
		for i in range(gd_fields.size()):
			var f = gd_fields[i]
			print("    field[", i, "]  name='", f.name, "'  type='", f.current_type, "'")
		print("=========================")

		assert(reflection.test(schema_type), "Can not detect schema type")

	func set_state(decoder):
		state.decode(decoder)

	func get_state():
		return state

	func patch(decoder):
		state.decode(decoder)

static func getSerializer(id: String, schema_type: GDScript = null) -> Serializer:
	match id:
		"schema":
			return SchemaSerializer.new(schema_type)
		"none":
			return NoneSerializer.new()
	return null
