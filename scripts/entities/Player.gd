extends CharacterBody2D
class_name Player

# References
@onready var grid_manager: GridManager = get_node("/root/Ingame/GridManager")
@onready var sprite: Sprite2D = $Sprite

# Textures
var texture_still: Texture2D = preload("res://assets/gorgeous.png")
var texture_walking: Texture2D = preload("res://assets/walking.png")

# Sprite size (slightly smaller than grid cell)
const SPRITE_SIZE = 180.0  # pixels

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
enum MaskType { NONE, DIMENSION, WATER }
var current_mask: MaskType = MaskType.NONE
var inventory: Array[MaskType] = []  # Masks the player has collected

# Player state (NULL state by default)
var is_intangible: bool = false  # Can walk through walls when true

# Dimension system
var current_dimension: int = 0
const NUM_DIMENSIONS: int = 2  # Change this if you have more dimensions

var properties: Array[String] = []  # Active properties from current mask

func _ready():
	# Snap to grid at start
	if grid_manager:
		grid_position = grid_manager.world_to_grid(global_position)
		global_position = grid_manager.grid_to_world(grid_position)

	# Start in NULL state (no mask)
	update_mask_properties()

	# Ensure all objects are set to the correct dimension visibility/collision at game start
	var ingame = get_tree().get_root().get_node("Ingame")
	if ingame:
		for group in ["Walls", "Water"]:
			if ingame.has_node(group):
				for obj in ingame.get_node(group).get_children():
					if obj.has_method("update_dimension_visibility"):
						obj.update_dimension_visibility(current_dimension)

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

	# Handle dimension switching (only if wearing DIMENSION mask)
	if Input.is_action_just_pressed("ui_accept"):  # Default: spacebar
		if current_mask == MaskType.DIMENSION:
			switch_dimension()

	# Handle pickup
	if Input.is_action_just_pressed("pickup"):  # E key
		try_pickup()

	# Handle equip mask
	if Input.is_action_just_pressed("equip_mask"):  # R key
		cycle_equipped_mask()

	# Process movement
	if is_moving:
		animate_movement(delta)
	elif next_move != Vector2i.ZERO and move_cooldown <= 0:
		# Execute the one buffered move
		var buffered_move = next_move
		next_move = Vector2i.ZERO
		try_move(buffered_move)

# Switch dimension and update all objects
func switch_dimension():
	current_dimension = (current_dimension + 1) % NUM_DIMENSIONS
	print("Switched to dimension ", current_dimension)
	# Notify all objects to update their visibility/collision
	var ingame = get_tree().get_root().get_node("Ingame")
	if ingame:
		for group in ["Walls", "Water"]:
			if ingame.has_node(group):
				for obj in ingame.get_node(group).get_children():
					if obj.has_method("update_dimension_visibility"):
						obj.update_dimension_visibility(current_dimension)

# Try to pick up a mask at the current position
func try_pickup():
	var ingame = get_tree().get_root().get_node("Ingame")
	if not ingame or not ingame.has_node("Masks"):
		return

	# Check for masks at current grid position
	for mask_obj in ingame.get_node("Masks").get_children():
		if mask_obj.has_method("pickup"):
			var mask_grid_pos = grid_manager.world_to_grid(mask_obj.global_position)
			if mask_grid_pos == grid_position:
				# Pick up the mask
				var mask_type = mask_obj.mask_type
				if not inventory.has(mask_type):
					inventory.append(mask_type)
					print("Picked up ", MaskType.keys()[mask_type], " mask!")
					mask_obj.pickup()
					update_inventory_ui()
				return

# Cycle through equipped masks
func cycle_equipped_mask():
	if inventory.size() == 0:
		print("No masks in inventory!")
		return

	# Find current mask index in inventory
	var current_index = inventory.find(current_mask)

	# Cycle to next mask in inventory
	if current_index == -1:
		# No mask equipped, equip first in inventory
		wear_mask(inventory[0])
	else:
		# Cycle to next mask
		var next_index = (current_index + 1) % inventory.size()
		wear_mask(inventory[next_index])

# Update inventory UI
func update_inventory_ui():
	var ui = get_node_or_null("/root/Ingame/InventoryUI")
	if ui and ui.has_method("update_inventory"):
		ui.update_inventory(inventory, current_mask)

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
	# Check if position is within bounds
	if not grid_manager.is_valid_position(target_pos):
		return false

	# In NULL state (intangible), can move through solid objects
	if is_intangible:
		return true

	# Check for solid tiles (walls, water, etc.) in the current dimension
	if grid_manager.is_solid(target_pos, current_dimension):
		# Special case: if it's water and we have FLOAT property, we can pass
		if is_water_tile(target_pos) and has_property("FLOAT"):
			return true
		return false

	return true

func is_water_tile(target_pos: Vector2i) -> bool:
	# Check if there's a water object at this position
	var ingame = get_tree().get_root().get_node("Ingame")
	if not ingame or not ingame.has_node("Water"):
		return false

	for water_obj in ingame.get_node("Water").get_children():
		if grid_manager:
			var water_grid_pos = grid_manager.world_to_grid(water_obj.global_position)
			if water_grid_pos == target_pos:
				# Check if this water is in the current dimension
				if water_obj.has_method("update_dimension_visibility"):
					return water_obj.visible
				return true
	return false

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

# Mask management
func wear_mask(mask_type: MaskType):
	current_mask = mask_type
	update_mask_properties()
	update_inventory_ui()

func remove_mask():
	current_mask = MaskType.NONE
	update_mask_properties()

func update_mask_properties():
	properties.clear()
	is_intangible = false

	match current_mask:
		MaskType.NONE:
			# NULL state - solid by default, can't walk through walls or water
			is_intangible = false
			properties = []

		MaskType.DIMENSION:
			# DIMENSION - allows switching between dimensions with spacebar
			is_intangible = false
			properties = ["DIMENSION_SHIFT"]

		MaskType.WATER:
			# WATER - allows floating on water
			is_intangible = false
			properties = ["FLOAT"]

	print("Mask changed: ", MaskType.keys()[current_mask], " Properties: ", properties)

func has_property(property_name: String) -> bool:
	return properties.has(property_name)
