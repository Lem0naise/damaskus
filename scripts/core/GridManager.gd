extends Node
class_name GridManager

# Grid configuration
const TILE_SIZE = 64  # Size of each grid cell in pixels
const GRID_WIDTH = 30  # Number of tiles wide (1920 / 64)
const GRID_HEIGHT = 17  # Number of tiles tall (1088 / 64, rounded up)
var grid_offset = Vector2.ZERO  # Offset for centering the grid if needed

# Collision tracking (per-dimension)
var solid_tiles: Dictionary = {}  # dimension_id -> {grid_pos: true}

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

# Check if a grid position is valid (within bounds)
func is_valid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and \
		   grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT

# Register a solid tile at a grid position for a specific dimension
func set_solid(grid_pos: Vector2i, is_solid: bool = true, dimension_id: int = 0):
	if not solid_tiles.has(dimension_id):
		solid_tiles[dimension_id] = {}
	if is_solid:
		solid_tiles[dimension_id][grid_pos] = true
	else:
		solid_tiles[dimension_id].erase(grid_pos)

# Check if a grid position is solid (blocked) in a specific dimension
func is_solid(grid_pos: Vector2i, dimension_id: int = 0) -> bool:
	if solid_tiles.has(dimension_id):
		return solid_tiles[dimension_id].has(grid_pos)
	return false
