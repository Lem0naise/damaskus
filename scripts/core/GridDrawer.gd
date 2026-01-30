extends Node2D

@export var grid_size: int = 64
@export var grid_width: int = 20
@export var grid_height: int = 15
@export var line_color: Color = Color(0.3, 0.3, 0.3, 0.5)

func _ready():
	queue_redraw()

func _draw():
	# Draw vertical lines
	for x in range(grid_width + 1):
		var x_pos = x * grid_size
		draw_line(
			Vector2(x_pos, 0),
			Vector2(x_pos, grid_height * grid_size),
			line_color,
			1.0
		)

	# Draw horizontal lines
	for y in range(grid_height + 1):
		var y_pos = y * grid_size
		draw_line(
			Vector2(0, y_pos),
			Vector2(grid_width * grid_size, y_pos),
			line_color,
			1.0
		)
