extends CharacterBody2D
class_name Player

# References
@onready var grid_manager: GridManager = get_node("/root/Ingame/GridManager")

# Movement
var grid_position: Vector2i = Vector2i.ZERO
var is_moving: bool = false
var move_speed: float = 8.0  # Speed of grid transition animation

# Mask system
enum MaskType { NONE, GOLEM, SPIRIT, MIRROR, MIMIC }
var current_mask: MaskType = MaskType.NONE

# Player state (NULL state by default)
var is_intangible: bool = true  # Can walk through walls when true
var properties: Array[String] = []  # Active properties from current mask

func _ready():
	# Snap to grid at start
	if grid_manager:
		grid_position = grid_manager.world_to_grid(global_position)
		global_position = grid_manager.grid_to_world(grid_position)

	# Start in NULL state (no mask)
	update_mask_properties()

func _process(delta):
	if not is_moving:
		handle_input()
	else:
		animate_movement(delta)

func handle_input():
	var input_dir = Vector2i.ZERO

	# Get input direction
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_d"):
		input_dir = Vector2i.RIGHT
	elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_a"):
		input_dir = Vector2i.LEFT
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_s"):
		input_dir = Vector2i.DOWN
	elif Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_w"):
		input_dir = Vector2i.UP

	# Move if input detected
	if input_dir != Vector2i.ZERO:
		try_move(input_dir)

func try_move(direction: Vector2i):
	var target_grid_pos = grid_position + direction

	# Check if move is valid
	if can_move_to(target_grid_pos):
		grid_position = target_grid_pos
		is_moving = true

func can_move_to(target_pos: Vector2i) -> bool:
	# In NULL state (intangible), can move anywhere
	if is_intangible:
		return grid_manager.is_valid_position(target_pos)

	# When wearing a mask, check for collisions
	# TODO: Implement collision checking with walls and objects
	return grid_manager.is_valid_position(target_pos)

func animate_movement(delta):
	var target_world_pos = grid_manager.grid_to_world(grid_position)

	# Smoothly move towards target
	global_position = global_position.move_toward(target_world_pos, move_speed * delta * grid_manager.TILE_SIZE)

	# Check if reached target
	if global_position.distance_to(target_world_pos) < 0.1:
		global_position = target_world_pos
		is_moving = false
		on_movement_complete()

func on_movement_complete():
	# Called when player reaches a new grid cell
	# TODO: Check for pickups, triggers, etc.
	pass

# Mask management
func wear_mask(mask_type: MaskType):
	current_mask = mask_type
	update_mask_properties()

func remove_mask():
	current_mask = MaskType.NONE
	update_mask_properties()

func update_mask_properties():
	properties.clear()
	is_intangible = true

	match current_mask:
		MaskType.NONE:
			# NULL state - intangible, no properties
			is_intangible = true

		MaskType.GOLEM:
			# SOLID, HEAVY, SINK
			is_intangible = false
			properties = ["SOLID", "HEAVY", "SINK"]

		MaskType.SPIRIT:
			# FLOAT, WEAK
			is_intangible = false
			properties = ["FLOAT", "WEAK"]

		MaskType.MIRROR:
			# REFLECT
			is_intangible = false
			properties = ["SOLID", "REFLECT"]

		MaskType.MIMIC:
			# COPY
			is_intangible = false
			properties = ["SOLID", "COPY"]

	print("Mask changed: ", MaskType.keys()[current_mask], " Properties: ", properties)

func has_property(property_name: String) -> bool:
	return properties.has(property_name)
