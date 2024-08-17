class_name Tile
extends RefCounted

var gridPos : Vector2
var entity : Entity = null
var walkable := false

func is_walkable() -> bool:
	if entity != null:
		if not entity.walkable:
			return false
	return self.walkable
