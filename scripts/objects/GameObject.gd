extends Node2D
class_name GameObject

# Grid references
@onready var grid_manager: GridManager = get_node("/root/Ingame/GridManager")

# Grid position
var grid_position: Vector2i = Vector2i.ZERO

# Object properties
var is_solid: bool = false  # Blocks movement
var is_pushable: bool = false  # Can be pushed
var object_type: String = "base"  # Type identifier for future extension

func _ready():
	# Calculate grid position from world position
	if grid_manager:
		grid_position = grid_manager.world_to_grid(global_position)
		register_with_grid()

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
