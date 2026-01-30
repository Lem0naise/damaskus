@tool
extends Node2D
class_name GameObject

# Grid configuration (must match GridManager)
const TILE_SIZE = 64
const GRID_OFFSET = Vector2.ZERO

# Grid references
@onready var grid_manager: GridManager = get_node_or_null("/root/Ingame/GridManager")

# Grid position
var grid_position: Vector2i = Vector2i.ZERO

# Object properties
var is_solid: bool = false  # Blocks movement
var is_pushable: bool = false  # Can be pushed
var object_type: String = "base"  # Type identifier for future extension

# Editor snapping
var last_position: Vector2 = Vector2.ZERO

func _ready():
	if Engine.is_editor_hint():
		# In editor - snap to grid immediately
		snap_to_grid_editor()
	else:
		# In game - calculate grid position and register
		if grid_manager:
			grid_position = grid_manager.world_to_grid(global_position)
			register_with_grid()

func _process(_delta):
	if Engine.is_editor_hint():
		# Snap to grid when moved in editor
		if position != last_position:
			snap_to_grid_editor()
			last_position = position

func snap_to_grid_editor():
	# Snap position to nearest grid cell center
	var adjusted_pos = position - GRID_OFFSET
	var grid_x = round(adjusted_pos.x / TILE_SIZE)
	var grid_y = round(adjusted_pos.y / TILE_SIZE)
	position = Vector2(
		grid_x * TILE_SIZE + TILE_SIZE / 2.0,
		grid_y * TILE_SIZE + TILE_SIZE / 2.0
	) + GRID_OFFSET
	last_position = position

func register_with_grid():
	# Register this object with the grid manager
	if is_solid:
		grid_manager.set_solid(grid_position, true)

func unregister_from_grid():
	# Remove this object from grid
	if is_solid:
		grid_manager.set_solid(grid_position, false)

# Override this for custom behavior when player interacts
func on_player_interact():
	pass

# Override this for custom behavior when pushed
func on_pushed(direction: Vector2i) -> bool:
	return false  # Return true if push was successful
