# Путь: scripts/Konstantin.gd
extends Node2D

@export var walk_speed: float = 320.0
var target_x: float = 400.0
var is_walking: bool = false
var facing_left: bool = false

@onready var visual: Node2D = $Visual

func _ready() -> void:
	target_x = global_position.x

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		walk_to(get_global_mouse_position().x)

func walk_to(x_pos: float) -> void:
	target_x = clamp(x_pos, 180.0, 1740.0)
	is_walking = true
	
	if target_x < global_position.x:
		facing_left = true
		visual.scale.x = -1.0
	elif target_x > global_position.x:
		facing_left = false
		visual.scale.x = 1.0

func _process(delta: float) -> void:
	if is_walking:
		global_position.x = move_toward(global_position.x, target_x, walk_speed * delta)
		# Эффект бумажной марионетки при ходьбе
		visual.position.y = sin(Time.get_ticks_msec() * 0.016) * 5.0
		
		if is_equal_approx(global_position.x, target_x):
			is_walking = false
			visual.position.y = 0.0