extends Node2D

signal time_changed(seconds_left: float)
signal bulb_lit
signal beam_failed

const MAX_LENGTH := 3000.0
const MAX_BOUNCES := 10
const EPSILON := 0.5

@export var time_limit := 30.0

var time_left := 0.0
var finished := false

@onready var line: Line2D = $Line2D

func _ready() -> void:
	line.top_level = true
	line.global_transform = Transform2D.IDENTITY
	time_left = time_limit

func _physics_process(delta: float) -> void:
	if finished:
		return

	var space := get_world_2d().direct_space_state
	var pos := global_position
	var dir := Vector2.RIGHT.rotated(global_rotation)
	var points := PackedVector2Array([global_position])
	var lit := false

	for i in MAX_BOUNCES:
		var end_point := pos + dir * MAX_LENGTH
		var query := PhysicsRayQueryParameters2D.create(pos, end_point)
		query.collide_with_areas = true
		var hit := space.intersect_ray(query)

		if hit.is_empty():
			points.append(end_point)
			break

		var hit_pos: Vector2 = hit.position
		var normal: Vector2 = hit.normal
		var collider := hit.collider as Node
		points.append(hit_pos)		
		print(collider.name," ",collider.get_groups())

		if collider.is_in_group("bulb"):
			lit = true
			if collider.has_method("light_up"):
				collider.call("light_up")
			break

		if not (collider.is_in_group("wall") or collider.is_in_group("mirror")):
			break

		dir = dir.bounce(normal)
		pos = hit_pos + dir * EPSILON

	line.points = points

	if lit:
		finished = true
		bulb_lit.emit()
		print("You win")
		return

	time_left = maxf(time_left - delta, 0.0)
	time_changed.emit(time_left)

	if time_left <= 0.0:
		finished = true
		beam_failed.emit()
		print("Time up")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			get_tree().reload_current_scene()
