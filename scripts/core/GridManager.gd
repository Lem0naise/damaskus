extends Node
class_name GridManager

# Grid configuration
const TILE_SIZE = 64  # Size of each grid cell in pixels
var grid_offset = Vector2.ZERO  # Offset for centering the grid if needed

# Convert world position to grid coordinates
func world_to_grid(world_pos: Vector2) -> Vector2i:
	var adjusted_pos = world_pos - grid_offset
	return Vector2i(
		int(floor(adjusted_pos.x / TILE_SIZE)),
		int(floor(adjusted_pos.y / TILE_SIZE))
	)

# Convert grid coordinates to world position (center of cell)
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2.0,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2.0
	) + grid_offset

# Snap world position to grid
func snap_to_grid(world_pos: Vector2) -> Vector2:
	var grid_pos = world_to_grid(world_pos)
	return grid_to_world(grid_pos)

# Check if a grid position is valid (you can expand this with bounds checking)
func is_valid_position(grid_pos: Vector2i) -> bool:
	# For now, all positions are valid
	# You can add level bounds checking here later
	return true
