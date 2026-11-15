extends Area2D

func _ready() -> void:
	add_to_group("bulb")
	modulate = Color(0.4, 0.4, 0.4)

func light_up() -> void:
	modulate = Color(1.0, 1.0, 0.5)
