extends Node2D

@export var grid_size: int = 64
@export var grid_width: int = 30
@export var grid_height: int = 17
@export var line_color: Color = Color(0.3, 0.3, 0.3, 0.5)

func _ready():
	queue_redraw()

func _draw():
	pass
