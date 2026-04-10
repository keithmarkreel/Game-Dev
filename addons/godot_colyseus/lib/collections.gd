extends Object

const EventListener = preload("res://addons/godot_colyseus/lib/listener.gd")
const SchemaInterface = preload("res://addons/godot_colyseus/lib/schema_interface.gd")

class Collection extends SchemaInterface:
	var sub_type
	var _on_add: EventListener = EventListener.new()
	var _on_remove: EventListener = EventListener.new()
	var _on_change: EventListener = EventListener.new()

	func on_add(callback: Callable):
		_on_add.once(callback)

	func on_remove(callback: Callable):
		_on_remove.once(callback)

	func on_change(callback: Callable):
		_on_change.once(callback)

	func meta_get_subtype(index):
		return sub_type

class ArraySchema extends Collection:
	var items = []

	func clear(decoding: bool = false):
		items.clear()
	func meta_get(index):
		if items.size() > index:
			return items[index]
		return null
	func meta_get_key(index):
		return str(index)
	func meta_set(index, key, value):
		var is_new = items.size() <= index
		_set_item(index, value)
		if is_new:
			_on_add.emit([value, index])
		else:
			_on_change.emit([value, index])
	func meta_remove(index):
		assert(items.size() > index)
		var value = items[index]
		items.remove_at(index)
		_on_remove.emit([value, index])

	func _set_item(index, value):
		if items.size() > index:
			items[index] = value
		else:
			while items.size() < index - 1:
				items.append(null)
			items.append(value)

	func meta_set_self(value):
		items = value

	func at(index: int):
		return items[index]

	func size() -> int:
		return items.size()

	func _to_string():
		return JSON.stringify(items)

	func to_object():
		return items

class MapSchema extends Collection:
	var _keys = {}
	var items = {}
	var _counter = 0

	func clear(decoding: bool = false):
		items.clear()
		_keys.clear()
		_counter = 0
	func meta_get(index):
		if _keys.has(index):
			return items[_keys[index]]
		return null
	func meta_get_key(index):
		if not _keys.has(index):
			return index
		return _keys[index]
	func meta_set(index, key, value):
		var is_new = not items.has(key)
		_keys[index] = key
		items[key] = value
		if is_new:
			_on_add.emit([value, key])
		else:
			_on_change.emit([value, key])
	func meta_remove(index):
		if not _keys.has(index):
			return
		var key = _keys[index]
		var value = items[key]
		items.erase(key)
		_keys.erase(index)
		_on_remove.emit([value, key])

	func at(key: String):
		return items.get(key)

	func put(key: String, value):
		_keys[_counter] = key
		items[key] = value
		_on_add.emit([value, key])
		_counter += 1

	func _to_string():
		return JSON.stringify(items)

	func to_object():
		return items

	func keys():
		var list = []
		for k in _keys:
			list.append(_keys[k])
		return list

	func size():
		return _keys.size()

	func has(key: String):
		return items.has(key)

class SetSchema extends Collection:
	var _counter = 0
	var items = {}

	func clear(decoding: bool = false):
		items.clear()
		_counter = 0
	func meta_get(index):
		if items.size() > index:
			return items[index]
		return null
	func meta_get_key(index):
		return str(index)
	func meta_set(index, key, value):
		var is_new = not items.has(index)
		_set_item(index, value)
		if is_new:
			_on_add.emit([value, index])
	func meta_remove(index):
		var value = items.get(index)
		items.erase(index)
		_on_remove.emit([value, index])

	func _set_item(index, value):
		if items.size() > index:
			items[index] = value
		else:
			while items.size() < index - 1:
				items.append(null)
			items.append(value)

	func _to_string():
		return JSON.stringify(items)

	func to_object():
		return items

class CollectionSchema extends Collection:
	var items = []

	func clear(decoding: bool = false):
		items.clear()
	func meta_get(index):
		if items.size() > index:
			return items[index]
		return null
	func meta_get_key(index):
		return str(index)
	func meta_set(index, key, value):
		var is_new = items.size() <= index
		_set_item(index, value)
		if is_new:
			_on_add.emit([value, index])
	func meta_remove(index):
		var value = items[index] if items.size() > index else null
		items.erase(index)
		_on_remove.emit([value, index])

	func _set_item(index, value):
		if items.size() > index:
			items[index] = value
		else:
			while items.size() < index - 1:
				items.append(null)
			items.append(value)

	func _to_string():
		return JSON.stringify(items)

	func to_object():
		return items
