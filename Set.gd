class_name  Set


var temp_keys: Array
var i: int

var values: Dictionary = {}


func add(elem: Variant) -> void:
	values[elem] = null


func add_all(iterable: Variant) -> void:
	for elem in iterable:
		add(elem)


func erase(elem: Variant) -> bool:
	return values.erase(elem)


func has(elem: Variant) -> bool:
	return values.has(elem)


func is_empty() -> bool:
	return values.is_empty()


func size() -> int:
	return values.size()


func get_first() -> Variant:
	return values.keys()[0]


func pop_front() -> Variant:
	var value = values.keys()[0]
	values.erase(value)
	return value


func pick_random() -> Variant:
	return values.keys().pick_random()


func clear() -> void:
	values.clear()


func keys() -> Array:
	return values.keys()


static func from(iterable: Variant) -> Set:
	var new_set: Set = Set.new()
	for elem in iterable:
		new_set.add(elem)
	return new_set


func _to_string() -> String:
	var string: String = "{ "
	for elem in values:
		string += str(elem) + " "
	string += "}"
	return string


func _iter_init(_arg: Variant):
	temp_keys = values.keys()
	i = 0
	return not temp_keys.is_empty()


func _iter_next(_arg: Variant):
	i += 1
	return i < temp_keys.size()


func _iter_get(_arg: Variant):
	if not is_instance_valid(temp_keys[i]):
		return null
	return temp_keys[i]
