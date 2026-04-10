extends RefCounted

class Promise extends RefCounted:
	enum State { Waiting, Resolved, Failed }
	
	signal completed
	
	var _state: State = State.Waiting
	var _data = null
	var _error = null
	
	func resolve(data = null):
		_data = data
		_state = State.Resolved
		emit_signal("completed")
	
	func reject(error = null):
		_error = error
		_state = State.Failed
		emit_signal("completed")
	
	func get_state() -> State:
		return _state
	
	func get_data():
		return _data
	
	func get_error():
		return _error
	
	func then(callable: Callable) -> Promise:
		var next = Promise.new()
		completed.connect(func():
			if _state == State.Resolved:
				var result = callable.call(_data, next)
				if result != null:
					next.resolve(result)
			else:
				next.reject(_error)
		)
		return next

class RunPromise extends Promise:
	func _init(callable: Callable, args: Array = []):
		callable.bindv([self] + args).call()
