extends Node
## Autoload: scene flow shared by all levels (Esc = level select, win = next level).

const LEVEL_SELECT_SCENE: String = "res://level_select.tscn"
const LEVEL_PATH_TEMPLATE: String = "res://level%d.tscn"
const LEVEL_COUNT: int = 10
const WIN_DELAY_SEC: float = 1.5

var _level_regex: RegEx = RegEx.create_from_string("^res://level(\\d+)\\.tscn$")


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _current_level() > 0:
		_change_scene(LEVEL_SELECT_SCENE)


func _on_node_added(node: Node) -> void:
	if node.name == &"Emitter" and node.has_signal(&"bulb_lit"):
		node.connect(&"bulb_lit", _on_bulb_lit, CONNECT_ONE_SHOT)


func _on_bulb_lit() -> void:
	var level: int = _current_level()
	if level <= 0:
		return
	var scene: Node = get_tree().current_scene
	await get_tree().create_timer(WIN_DELAY_SEC).timeout
	if get_tree().current_scene != scene:
		return
	if level < LEVEL_COUNT:
		_change_scene(LEVEL_PATH_TEMPLATE % (level + 1))
	else:
		_change_scene(LEVEL_SELECT_SCENE)


## Returns the current level number (1-based), or 0 when not inside a level.
func _current_level() -> int:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return 0
	var result: RegExMatch = _level_regex.search(scene.scene_file_path)
	if result == null:
		return 0
	return result.get_string(1).to_int()


func _change_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Scene not found: %s" % path)
		return
	var err: Error = get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("Failed to load %s (error %d)" % [path, err])
