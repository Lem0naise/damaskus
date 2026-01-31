extends Node
class_name GridManager

# Configuration
const TILE_SIZE = 128
const GRID_WIDTH = 15 # 1920 / 128 
const GRID_HEIGHT = 9 # 1080 / 128
var grid_offset = Vector2.ZERO

# Define Tile Types
enum TileType { EMPTY, WALL, CRUMBLED_WALL, WATER, OBSTACLE, MASK }

# Storage: dimension_id -> { Vector2i: TileType }
var grid_data: Dictionary = {} 

func _ready():
	# Initialize dictionary for default dimension
	grid_data[0] = {}

# --- Conversion Helpers ---
func world_to_grid(world_pos: Vector2) -> Vector2i:
	var adjusted_pos = world_pos - grid_offset
	return Vector2i(
		int(floor(adjusted_pos.x / TILE_SIZE)),
		int(floor(adjusted_pos.y / TILE_SIZE))
	)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2.0,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2.0
	) + grid_offset

func is_valid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and \
		   grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT

# --- Content Management ---
func set_tile(grid_pos: Vector2i, type: TileType, dimension_id: int = 0):
	if not grid_data.has(dimension_id):
		grid_data[dimension_id] = {}
	
	if type == TileType.EMPTY:
		grid_data[dimension_id].erase(grid_pos)
	else:
		grid_data[dimension_id][grid_pos] = type

func get_tile_type(grid_pos: Vector2i, dimension_id: int = 0) -> TileType:
	if grid_data.has(dimension_id) and grid_data[dimension_id].has(grid_pos):
		return grid_data[dimension_id][grid_pos]
	return TileType.EMPTY

# Replaces your old is_solid check
func is_solid(grid_pos: Vector2i, dimension_id: int = 0) -> bool:
	var type = get_tile_type(grid_pos, dimension_id)
	return type == TileType.WALL or type == TileType.CRUMBLED_WALL # Water is not "solid" in the traditional sense, handled separately
