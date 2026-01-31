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
@export var dimension_ids: Array = [0]  # List of dimensions this object exists in
var is_pushable: bool = false  # Can be pushed
var object_type: String = "base"  # Type identifier for future extension

# Editor snapping - use a timer to detect when dragging stops
var snap_timer: float = 0.0
var last_position: Vector2 = Vector2.ZERO
const SNAP_DELAY = 0.1  # Snap after 0.1s of no movement

func _ready():
	if Engine.is_editor_hint():
		# In editor - enable transform notifications and snap immediately
		set_notify_transform(true)
		snap_to_grid_editor()
		last_position = position
	else:
		# In game - calculate grid position and register
		if grid_manager:
			grid_position = grid_manager.world_to_grid(global_position)
			register_with_grid()

func _process(delta):
	if Engine.is_editor_hint():
		# Check if position has changed
		if position != last_position:
			# Position changed - reset snap timer
			snap_timer = SNAP_DELAY
			last_position = position
		elif snap_timer > 0:
			# Position hasn't changed - count down timer
			snap_timer -= delta
			if snap_timer <= 0:
				# Timer expired - snap to grid
				snap_to_grid_editor()

func snap_to_grid_editor():
	# Snap local position to nearest grid cell center
	var grid_x = round(position.x / TILE_SIZE)
	var grid_y = round(position.y / TILE_SIZE)

	var target_pos = Vector2(
		grid_x * TILE_SIZE + TILE_SIZE / 2.0,
		grid_y * TILE_SIZE + TILE_SIZE / 2.0
	)

	# Only update if actually different (avoid infinite loops)
	if position.distance_to(target_pos) > 0.01:
		position = target_pos
		last_position = position

func register_with_grid():
	# Register this object with the grid manager
	if is_solid:
		for dim in dimension_ids:
			grid_manager.set_solid(grid_position, true, dim)

func unregister_from_grid():
	# Remove this object from grid
	if is_solid:
		for dim in dimension_ids:
			grid_manager.set_solid(grid_position, false, dim)

func update_dimension_visibility(active_dimension: int):
	visible = active_dimension in dimension_ids
	if has_node("CollisionShape2D"):
		get_node("CollisionShape2D").disabled = not (active_dimension in dimension_ids)

# Override this for custom behavior when player interacts
func on_player_interact():
	pass

# Override this for custom behavior when pushed
func on_pushed(direction: Vector2i) -> bool:
	return false  # Return true if push was successful
