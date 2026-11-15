extends Control

const LEVEL_PATH_TEMPLATE: String = "res://level%d.tscn"
const HOME_SCENE: String = "res://homepage.tscn"

@onready var _level_grid: GridContainer = $Center/Content/LevelGrid


func _ready() -> void:
	var level_number: int = 1
	for child: Node in _level_grid.get_children():
		var button: Button = child as Button
		if button == null:
			continue
		button.pressed.connect(_on_level_pressed.bind(level_number))
		level_number += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_change_scene(HOME_SCENE)


func _on_level_pressed(level_number: int) -> void:
	_change_scene(LEVEL_PATH_TEMPLATE % level_number)


func _change_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Scene not found: %s" % path)
		return
	var err: Error = get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("Failed to load %s (error %d)" % [path, err])
