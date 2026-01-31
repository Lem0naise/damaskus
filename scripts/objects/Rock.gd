extends GameObject
class_name Rock

# Track current position and state
var current_grid_position: Vector2i = Vector2i.ZERO
var is_on_water: bool = false
var move_duration: float = 0.18

func _ready():
	super._ready()
	if grid_manager:
		current_grid_position = grid_manager.world_to_grid(global_position)

# Get current grid position for lookups
func get_grid_position() -> Vector2i:
	return current_grid_position

# Called when player tries to push the rock
func on_pushed(direction: Vector2i) -> bool:
	if not grid_manager:
		return false

	var target_pos = current_grid_position + direction

	# Check if target position is valid
	if not grid_manager.is_valid_position(target_pos):
		return false

	# Check what's at the target position
	var target_tile = grid_manager.get_tile_type(target_pos)

	# If rock is on water, it can ONLY be pushed to other water tiles (not back to land)
	if is_on_water:
		if target_tile != GridManager.TileType.WATER:
			return false  # Can't push rock from water back onto land
	else:
		# Rock is on land, can be pushed to EMPTY or WATER tiles
		if target_tile != GridManager.TileType.EMPTY and target_tile != GridManager.TileType.WATER:
			return false

	# If we're currently on water, restore the water tile
	if is_on_water:
		grid_manager.set_tile(current_grid_position, GridManager.TileType.WATER)
		is_on_water = false
	else:
		# We were on empty ground, restore it
		grid_manager.set_tile(current_grid_position, GridManager.TileType.EMPTY)

	# Update position
	current_grid_position = target_pos

	# Check if we're now on water
	if target_tile == GridManager.TileType.WATER:
		is_on_water = true

	# Set the new position to ROCK type
	grid_manager.set_tile(current_grid_position, GridManager.TileType.ROCK)

	# Animate the movement
	var target_world_pos = grid_manager.grid_to_world(current_grid_position)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_world_pos, move_duration)

	return true
