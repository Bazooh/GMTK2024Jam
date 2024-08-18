class_name Useful


static func sort(a, key = null) -> Array:
	if key == null:
		key = func(x): return x
	
	var map = a.map(key)
	var indices = range(a.size())
	indices.sort_custom(func(x, y): return map[x] < map[y])

	return indices.map(func(x): return a[x])


static func get_direction(a: Vector2) -> String:
	var angle: float = rad_to_deg(a.angle())

	if 45 <= angle and angle < 135:
		return "down"
	if angle >= 135 or angle < -135:
		return "left"
	if -135 <= angle and angle < -45:
		return "up"
	if -45 <= angle and angle < 45:
		return "right"
	return ""


static func animate(object, property: String, value, duration) -> void:
	var tween = object.create_tween()
	tween.tween_property(object, property, value, duration)
	await tween.finished
	tween.kill()


static func get_rect2i_border(rect: Rect2i, in_thickness: int = 1, out_thickness: int = 1) -> Array:
	var outside_rect: Rect2i = rect.grow(out_thickness)
	var inside_rect: Rect2i = rect.grow(-in_thickness)

	var border: Array = []
	for x in range(outside_rect.position.x, outside_rect.position.x + outside_rect.size.x):
		for y in range(outside_rect.position.y, outside_rect.position.y + outside_rect.size.y):
			var case: Vector2i = Vector2i(x, y)
			if not inside_rect.has_point(case):
				border.append(case)
	
	return border


static func get_bounds(a: Array) -> Rect2:
	var min_x: float = INF
	var min_y: float = INF
	var max_x: float = -INF
	var max_y: float = -INF

	for item: Vector2 in a:
		min_x = min(min_x, item.x)
		min_y = min(min_y, item.y)
		max_x = max(max_x, item.x)
		max_y = max(max_y, item.y)

	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)


static func get_boundsi(a: Array) -> Rect2i:
	var min_x := int(INF)
	var min_y := int(INF)
	var max_x := int(-INF)
	var max_y := int(-INF)

	for item: Vector2i in a:
		min_x = min(min_x, item.x)
		min_y = min(min_y, item.y)
		max_x = max(max_x, item.x)
		max_y = max(max_y, item.y)

	return Rect2i(min_x, min_y, max_x - min_x, max_y - min_y)