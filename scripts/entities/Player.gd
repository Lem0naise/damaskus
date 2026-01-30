extends CharacterBody2D
class_name Player

# References
@onready var grid_manager: GridManager = get_node("/root/Ingame/GridManager")
@onready var sprite: Sprite2D = $Sprite

# Textures
var texture_still: Texture2D = preload("res://assets/gorgeous.png")
var texture_walking: Texture2D = preload("res://assets/walking.png")

# Sprite size (slightly smaller than grid cell)
const SPRITE_SIZE = 48.0  # pixels

# Movement
var grid_position: Vector2i = Vector2i.ZERO
var is_moving: bool = false
var move_speed: float = 15.0  # Speed of grid transition animation

# Input buffering
var next_move: Vector2i = Vector2i.ZERO  # Only buffer one move
var move_cooldown: float = 0.0
const HELD_KEY_DELAY = 0.12  # Delay between moves when holding a key
const HELD_KEY_INITIAL_DELAY = 0.25  # Initial delay before key starts repeating
var held_key_timer: float = 0.0
var last_held_direction: Vector2i = Vector2i.ZERO

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

	# Set initial sprite
	set_sprite_texture(texture_still)

func _process(delta):
	# Update cooldown timer
	if move_cooldown > 0:
		move_cooldown -= delta

	# Update held key timer
	if held_key_timer > 0:
		held_key_timer -= delta

	# Handle input
	handle_input()

	# Process movement
	if is_moving:
		animate_movement(delta)
	elif next_move != Vector2i.ZERO and move_cooldown <= 0:
		# Execute the one buffered move
		var buffered_move = next_move
		next_move = Vector2i.ZERO
		try_move(buffered_move)

func handle_input():
	var input_dir = Vector2i.ZERO
	var is_just_pressed = false

	# Check for just_pressed input (highest priority - always register)
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_d"):
		input_dir = Vector2i.RIGHT
		is_just_pressed = true
		held_key_timer = HELD_KEY_INITIAL_DELAY
		last_held_direction = input_dir
	elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_a"):
		input_dir = Vector2i.LEFT
		is_just_pressed = true
		held_key_timer = HELD_KEY_INITIAL_DELAY
		last_held_direction = input_dir
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_s"):
		input_dir = Vector2i.DOWN
		is_just_pressed = true
		held_key_timer = HELD_KEY_INITIAL_DELAY
		last_held_direction = input_dir
	elif Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_w"):
		input_dir = Vector2i.UP
		is_just_pressed = true
		held_key_timer = HELD_KEY_INITIAL_DELAY
		last_held_direction = input_dir

	# If no just_pressed, check for held keys (only after initial delay)
	if not is_just_pressed and not is_moving and move_cooldown <= 0 and held_key_timer <= 0:
		if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_d"):
			input_dir = Vector2i.RIGHT
		elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_a"):
			input_dir = Vector2i.LEFT
		elif Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_s"):
			input_dir = Vector2i.DOWN
		elif Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_w"):
			input_dir = Vector2i.UP
		else:
			# No keys held, reset timer
			held_key_timer = 0
			last_held_direction = Vector2i.ZERO

	# Process the input
	if input_dir != Vector2i.ZERO:
		if is_moving:
			# Only buffer ONE move, and only the most recent
			next_move = input_dir
		elif move_cooldown <= 0:
			# Execute immediately
			try_move(input_dir)

func try_move(direction: Vector2i):
	var target_grid_pos = grid_position + direction

	# Check if move is valid
	if can_move_to(target_grid_pos):
		grid_position = target_grid_pos
		is_moving = true
		set_sprite_texture(texture_walking)

		# Flip sprite horizontally based on left/right movement
		if direction == Vector2i.LEFT:
			sprite.flip_h = true
		elif direction == Vector2i.RIGHT:
			sprite.flip_h = false

		move_cooldown = HELD_KEY_DELAY  # Set cooldown for next move

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
		set_sprite_texture(texture_still)
		on_movement_complete()

func on_movement_complete():
	# Called when player reaches a new grid cell
	# TODO: Check for pickups, triggers, etc.
	pass

# Helper function to set sprite texture and scale it to consistent size
func set_sprite_texture(texture: Texture2D):
	if not sprite:
		sprite = $Sprite
	if not sprite:
		print("ERROR: Sprite node not found!")
		return

	sprite.texture = texture
	if texture:
		var texture_size = texture.get_size()
		var scale_factor = SPRITE_SIZE / max(texture_size.x, texture_size.y)
		sprite.scale = Vector2(scale_factor, scale_factor)
		print("Set sprite texture, size: ", texture_size, " scale: ", scale_factor)

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
