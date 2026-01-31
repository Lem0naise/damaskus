extends Node
class_name GridManager

# Configuration
const TILE_SIZE = 128
const GRID_WIDTH = 15 # 1920 / 128
const GRID_HEIGHT = 9 # 1080 / 128
var grid_offset = Vector2.ZERO

# Define Tile Types
enum TileType {EMPTY, WALL, CRUMBLED_WALL, WATER, OBSTACLE, MASK, ROCK, RED_WALL, BLUE_WALL, QUICKSAND}

# Storage: Vector2i -> TileType (single dimension)
var grid_data: Dictionary = {}

# Universal dimension state (shared by all entities)
var is_red_mode: bool = true  # true = red dimension, false = blue dimension

func _ready():
	pass

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
func set_tile(grid_pos: Vector2i, type: TileType):
	if type == TileType.EMPTY:
		grid_data.erase(grid_pos)
	else:
		grid_data[grid_pos] = type

func get_tile_type(grid_pos: Vector2i) -> TileType:
	if grid_data.has(grid_pos):
		return grid_data[grid_pos]
	return TileType.EMPTY

# Replaces your old is_solid check
func is_solid(grid_pos: Vector2i) -> bool:
	var type = get_tile_type(grid_pos)
	return type == TileType.WALL or type == TileType.CRUMBLED_WALL or \
		   type == TileType.RED_WALL or type == TileType.BLUE_WALL

func is_deadly(grid_pos: Vector2i) -> bool:
	print("checking deadliness")
	var type = get_tile_type(grid_pos)
	# Add any deadly tile types here
	return type == TileType.QUICKSAND
