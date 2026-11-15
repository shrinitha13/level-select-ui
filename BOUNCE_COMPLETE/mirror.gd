extends StaticBody2D

@export var step_deg := 15.0


func _ready() -> void:
	add_to_group("mirror")


func _is_target() -> bool:
	var mouse := get_global_mouse_position()
	var best: Node2D = null
	var best_dist := INF
	for node in get_tree().get_nodes_in_group("mirror"):
		var m := node as Node2D
		var d := m.global_position.distance_to(mouse)
		if d < best_dist:
			best_dist = d
			best = m
	return best == self


func _process(_delta: float) -> void:
	modulate = Color(1.0, 1.0, 0.4) if _is_target() else Color.WHITE


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if not _is_target():
			return
		if event.keycode == KEY_E:
			rotation += deg_to_rad(step_deg)
		elif event.keycode == KEY_Q:
			rotation -= deg_to_rad(step_deg)
