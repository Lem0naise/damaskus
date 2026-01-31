extends CharacterBody2D

class_name Player

signal player_moved(direction: Vector2i)
signal player_interacted(action_name: String) # pickup, drop, space, etc

# References

@onready var grid_manager: GridManager = get_node("/root/Ingame/GridManager")

@onready var sprite: Sprite2D = $Sprite


const MENU_SCENE_PATH: String = "res://main_menu.tscn"


# Textures

var texture_still: Texture2D = preload("res://assets/SpriteStillTransparent.png")
var texture_walking: Texture2D = preload("res://assets/SpriteMovingTransparent.png")


@onready var mask_layer: TextureRect = $MaskLayer


@export var water_mask_still: Texture2D
@export var water_mask_walking: Texture2D

@export var win_mask_still: Texture2D
@export var win_mask_walking: Texture2D

@export var golem_mask_still: Texture2D
@export var golem_mask_walking: Texture2D

@export var battering_mask_still: Texture2D
@export var battering_mask_walking: Texture2D



var current_mask_still: Texture2D = null
var current_mask_walking: Texture2D = null

# Sprite size (slightly smaller than grid cell)

const SPRITE_SIZE = 180.0 # pixels


# Movement Configuration

var grid_position: Vector2i = Vector2i.ZERO

var is_moving: bool = false

# Lower number = Faster, Snappier (e.g. 0.15)

# Higher number = Slower, Heavier (e.g. 0.3)

var move_duration: float = 0.18


# Input buffering

var next_move: Vector2i = Vector2i.ZERO # Only buffer one move

var move_cooldown: float = 0.0

const HELD_KEY_DELAY = 0.12 # Delay between moves when holding a key

const HELD_KEY_INITIAL_DELAY = 0.25 # Initial delay before key starts repeating

var held_key_timer: float = 0.0

var last_held_direction: Vector2i = Vector2i.ZERO


# Mask system
enum MaskType {NONE, DIMENSION, WATER, WINNER, BATTERING_RAM, GOLEM}
var current_mask: MaskType = MaskType.NONE

var inventory: Array[MaskType] = [] # Masks the player has collected


# Player state (NULL state by default)

var is_intangible: bool = false # Can walk through walls when true

# Note: Phase mode is now stored globally in GridManager.is_red_mode

var properties: Array[String] = [] # Active properties from current mask


func _ready():
	# Snap to grid at start
	
	if grid_manager:
		global_position = grid_manager.grid_to_world(grid_position)
		grid_position = grid_manager.world_to_grid(global_position)


	# Start in NULL state (no mask)

	update_mask_properties()


	# Set initial sprite

	set_sprite_texture(texture_still)

	
	# Sync UI

	update_inventory_ui()


func _process(delta):
	# Update cooldown timer
	if move_cooldown > 0:
		move_cooldown -= delta


	# Update held key timer

	if held_key_timer > 0:
		held_key_timer -= delta


	# Handle input

	handle_input()


	# Handle phase mode switching (if player OR NPC has DIMENSION mask)

	if Input.is_action_just_pressed("ui_accept"): # Default: spacebar


		# Check if either player or NPC has DIMENSION mask
		var npc = get_node_or_null("/root/Ingame/NPC")
		var player_has_dimension = current_mask == MaskType.DIMENSION
		var npc_has_dimension = npc and npc.is_active and npc.current_mask == MaskType.DIMENSION

		if player_has_dimension or npc_has_dimension:
			toggle_phase_mode()

		player_interacted.emit("space") # NPC


	# Handle pickup

	if Input.is_action_just_pressed("pickup"): # E key
		
		try_pickup()
		
		
		player_interacted.emit("pickup") # NPC
		

	# Process movement buffer (Only if NOT currently moving)

	# The actual movement is now handled by the Tween, not manual delta updates

	if not is_moving and next_move != Vector2i.ZERO and move_cooldown <= 0:
		# Execute the one buffered move
		var buffered_move = next_move

		next_move = Vector2i.ZERO

		try_move(buffered_move)


# Toggle phase mode between red and blue (universal state)

func can_toggle_phase() -> bool:
	var dangerous_tile = GridManager.TileType.RED_WALL if grid_manager.is_red_mode else GridManager.TileType.BLUE_WALL
	if grid_manager.get_tile_type(grid_position) == dangerous_tile:
		print("Cannot phase player is blocking position!")
		return false
	var npc = get_node_or_null("/root/Ingame/NPC")
	if npc and npc.is_active:
		if grid_manager.get_tile_type(npc.grid_position) == dangerous_tile:
			print("cannot phase npc is blocking position!")
			return false
			
	return true
	
func toggle_phase_mode():
	if not can_toggle_phase(): return # TODO here flash red
	grid_manager.is_red_mode = not grid_manager.is_red_mode
	var mode_name = "RED" if grid_manager.is_red_mode else "BLUE"
	print("Player toggled universal dimension to ", mode_name, " mode")


# Try to pick up a mask at the current position
# Try to pick up a mask at the current position
func try_pickup():
	var ingame = get_tree().get_root().get_node("Ingame")
	if not ingame: return
	
	var level_gen = ingame.get_node_or_null("LevelGenerator")
	if not level_gen or not level_gen.has_node("Masks"): return

	# Check for masks at current grid position
	for mask_obj in level_gen.get_node("Masks").get_children():
		if mask_obj.get("is_picked_up"): 
			continue
			
		if mask_obj.has_method("pickup"):
			var mask_grid_pos = grid_manager.world_to_grid(mask_obj.global_position)
			
			if mask_grid_pos == grid_position:
				# --- SWAP LOGIC START ---
				
				# 1. If we are already holding a mask, drop it first
				if current_mask != MaskType.NONE:
					# Spawn the old mask at the current location
					level_gen.spawn_mask_at(grid_position, current_mask)
					print("Dropped old mask: ", MaskType.keys()[current_mask])
				
				# 2. Pick up the new mask
				var new_mask_type = mask_obj.mask_type
				wear_mask(new_mask_type)
				
				# 3. Remove the new mask from the floor (pickup)
				mask_obj.pickup() 
				
				update_tooltip_state()
					
				return
				
				
				# --- SWAP LOGIC END ---

# Equip mask at specific inventory index

func equip_mask_at_index(index: int):
	if index < 0 or index >= inventory.size():
		return # Mute invalid index
		
	var mask_type = inventory[index]
	
	if current_mask == mask_type:
		# Toggle off if already equipped
		remove_mask()
		print("Unequipped mask")
		return
	
	wear_mask(mask_type)
	print("Equipped ", MaskType.keys()[mask_type])

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var index = event.keycode - KEY_1

			equip_mask_at_index(index)


# Update inventory UI

func update_inventory_ui():
	var ui = get_node_or_null("/root/Ingame/InventoryUI")

	if ui and ui.has_method("update_inventory"):
		ui.update_inventory(inventory, current_mask)


func drop_mask():
	# 1. Check if we have a mask to drop
	if current_mask == MaskType.NONE:
		print("No mask to drop!")
		return

	# 2. Get references
	var ingame = get_tree().get_root().get_node("Ingame")
	if not ingame: return
	
	var level_gen = ingame.get_node_or_null("LevelGenerator")
	if not level_gen: return

	# 3. Spawn the mask item at current position
	# We use the existing spawn helper from LevelGenerator
	if level_gen.has_method("spawn_mask_at"):
		level_gen.spawn_mask_at(grid_position, current_mask)
		print("Dropped mask: ", MaskType.keys()[current_mask])
		
		# 4. Remove it from player
		remove_mask()
		
		# 5. Clear Inventory Data
		# Since we use inventory array in your code, we should clear it
		if inventory.has(current_mask):
			inventory.erase(current_mask)
		# Or just clear all since we only hold one
		inventory.clear() 
		
		# 6. Update UI
		update_inventory_ui()
		
		# 7. Check if we are now standing on a mask (the one we just dropped)
		# This ensures the pickup tooltip appears immediately
		update_tooltip_state()
			
	else:
		print("Error: LevelGenerator missing spawn_mask_at method")
		
		
func handle_input():
	var input_dir = Vector2i.ZERO

	var is_just_pressed = false


	if Input.is_action_just_pressed("drop_mask") or Input.is_key_pressed(KEY_Q):
			drop_mask()
			
			player_interacted.emit("drop") # NPC
			
			return # Don't move on the same frame you drop
			
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
	
	
	# Check if moving into a ROCK
	var tile_type = grid_manager.get_tile_type(target_grid_pos)
	if tile_type == GridManager.TileType.ROCK:
		# Find the rock to check if it's on water
		var ingame = get_tree().get_root().get_node("Ingame")
		if ingame and ingame.has_node("LevelGenerator/Rocks"):
			for rock in ingame.get_node("LevelGenerator/Rocks").get_children():
				if rock.has_method("get_grid_position") and rock.get_grid_position() == target_grid_pos:
					# Found the rock at target position
					if rock.is_on_water :
						# Rock is a bridge (on water) 
						# Allow walking on it - skip the push logic
						break
					elif has_property("PUSH_ROCKS"):
						# We have GOLEM mask - try to push the rock
						if not rock.on_pushed(direction):
							# Push failed, block movement
							return
						# Push succeeded, continue to move into old rock position
						break
					else:
						# Rock is not on water and we don't have GOLEM - block movement
						return
				# Note: If no rock found at position (shouldn't happen), movement continues

	# Check if moving into a CRUMBLED_WALL with proper equipment
	tile_type = grid_manager.get_tile_type(target_grid_pos)
	if tile_type == GridManager.TileType.CRUMBLED_WALL and has_property("BREAK_WALL"):
		# Destroy the wall!
		var ingame = get_tree().get_root().get_node("Ingame")

		if ingame and ingame.has_node("LevelGenerator/CrumbledWalls"):
			for wall in ingame.get_node("LevelGenerator/CrumbledWalls").get_children():
				if grid_manager.world_to_grid(wall.global_position) == target_grid_pos:
					wall.queue_free()

					grid_manager.set_tile(target_grid_pos, GridManager.TileType.EMPTY)

					print("Smashed a crumbled wall!")

					break


	# Check if move is valid

	if can_move_to(target_grid_pos):
		grid_position = target_grid_pos

		is_moving = true
		

		# Flip sprite horizontally based on left/right movement

		if direction == Vector2i.LEFT:
			sprite.flip_h = true

		elif direction == Vector2i.RIGHT:
			sprite.flip_h = false
			
		update_visuals()


		move_cooldown = HELD_KEY_DELAY

		
		# --- NEW SMOOTH TWEEN MOVEMENT ---

		var target_world_pos = grid_manager.grid_to_world(grid_position)

		
		# Create a tween for smooth movement
		
		if move_tween: move_tween.kill()
		move_tween = create_tween()

		# TRANS_SINE + EASE_OUT gives a natural slide

		move_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		move_tween.tween_property(self, "global_position", target_world_pos, move_duration)

		move_tween.tween_callback(on_movement_finished)


	player_moved.emit(direction) # emit signal for NPC
	
func on_movement_finished():
	# Called when tween finishes
	is_moving = false

	update_visuals()
	
	update_tooltip_state()

	# Check if the current tile is deadly and run die if so
	if grid_manager.is_deadly(grid_position):
		print("WOAHH")
		die()
		return

	# If player queued a move while sliding, execute it now for responsiveness

	if next_move != Vector2i.ZERO:
		var buffered_move = next_move

		next_move = Vector2i.ZERO

		try_move(buffered_move)


func can_move_to(target_pos: Vector2i) -> bool:
	# 1. Bounds check
	if not grid_manager.is_valid_position(target_pos):
		return false


	var npc = get_node_or_null("/root/Ingame/NPC")
	if npc and npc.is_active and npc.grid_position == target_pos:
		# The NPC is currently blocking us.
		# However, since the NPC copies our moves, if we move, THEY will move.
		# We need to check if the NPC has a valid place to go.
		
		# Calculate where the NPC would try to go
		var move_direction = target_pos - grid_position
		var npc_future_pos = npc.grid_position + move_direction
		
		# Ask the NPC: "Can you move to your next spot?"
		if npc.can_move_to(npc_future_pos):
			# YES: The NPC will vacate this tile, so we CAN move here.
			return true 
		else:
			# NO: The NPC is blocked (by a wall, etc), so we are effectively blocked.
			return false
	
	# 2. Intangible check

	if is_intangible:
		return true


	# 3. Check what type of tile is there

	var tile_type = grid_manager.get_tile_type(target_pos)


	match tile_type:
		GridManager.TileType.RED_WALL:
			# Can pass if player OR NPC has DIMENSION mask and in RED mode (universal)
			
			var anyone_has_dimension = has_property("DIMENSION_SHIFT") or (npc and npc.is_active and npc.has_property("DIMENSION_SHIFT"))
			if anyone_has_dimension and grid_manager.is_red_mode:
				return true
			return false

		GridManager.TileType.BLUE_WALL:
			# Can pass if player OR NPC has DIMENSION mask and in BLUE mode (universal)
	
			var anyone_has_dimension = has_property("DIMENSION_SHIFT") or (npc and npc.is_active and npc.has_property("DIMENSION_SHIFT"))
			if anyone_has_dimension and not grid_manager.is_red_mode:
				return true
			return false

		GridManager.TileType.WALL:
			return false # Always blocked by walls

		GridManager.TileType.LASER_EMITTER:
			return false # Laser emitters are solid like walls

		GridManager.TileType.WATER:
			# Only pass if we have FLOAT property
			if has_property("FLOAT"):
				return true

			return false # Blocked by water otherwise


		GridManager.TileType.CRUMBLED_WALL:
			# Only pass if we have BREAK_WALL property
			if has_property("BREAK_WALL"):
				return true
			return false # Blocked by crumbled wall otherwise

		GridManager.TileType.ROCK:
			# Rocks on water are walkable (bridge effect)
			var ingame = get_tree().get_root().get_node("Ingame")
			if ingame and ingame.has_node("LevelGenerator/Rocks"):
				for rock in ingame.get_node("LevelGenerator/Rocks").get_children():
					if rock.has_method("get_grid_position") and rock.get_grid_position() == target_pos:
						if rock.is_on_water:
							return true # Can walk on rock-on-water
						return false # Can't walk through rocks not on water
			return false

		GridManager.TileType.EMPTY:
			return true # Free to move

	return true

var move_tween: Tween

func reset_state():
	# 1. Stop Movement
	if move_tween: move_tween.kill()
	is_moving = false
	
	set_sprite_texture(texture_still)
	
func die():
	# TODO flash red
	remove_mask()
	# Call the IngameManager's reload_level function to reset the current level
	var ingame = get_tree().get_root().get_node("Ingame")
	if ingame and ingame.has_method("reload_level"):
		print("e")
		ingame.reload_level()
	elif ingame and ingame.has_node("IngameManager"):
		var manager = ingame.get_node("IngameManager")
		print("f")
		if manager and manager.has_method("reload_level"):
			manager.reload_level()
			print("e")
			
	else:
		print("Error: Could not find IngameManager to reload level.")


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

	# ALSO UPDATE THE MASK
	

# Mask management

func wear_mask(mask_type: MaskType):
	current_mask = mask_type
	update_mask_properties()
	update_inventory_ui()


func remove_mask():
	current_mask = MaskType.NONE

	update_mask_properties()

	update_inventory_ui()


func move_level():
	self.position = Vector2i(192, 192)
	
	self.grid_position = Vector2i(1, 1)
	
	
	
	remove_mask()
	
	inventory.clear()
	update_inventory_ui()
	
	
	
	update_tooltip_state()
	
	get_parent().next_level()
	
func update_mask_properties():
	properties.clear()

	is_intangible = false

	current_mask_still = null
	current_mask_walking = null
	if mask_layer:
		mask_layer.visible = false

	match current_mask:
		MaskType.NONE:
			# NULL state - solid by default, can't walk through walls or water
			is_intangible = false
			properties = []

		MaskType.DIMENSION:
			# DIMENSION - allows switching between dimensions with spacebar
			is_intangible = false
			properties = ["DIMENSION_SHIFT"]
			# Assign Dimension textures here if you have them later
			current_mask_still = golem_mask_still
			current_mask_walking = golem_mask_walking
			mask_layer.visible = true # Make sure to show it!

		MaskType.WATER:
			# WATER - allows floating on water
			is_intangible = false
			properties = ["FLOAT"]
			# --- ASSIGN WATER SPIRIT TEXTURES ---
			current_mask_still = water_mask_still
			current_mask_walking = water_mask_walking
			mask_layer.visible = true # Make sure to show it!
				
		MaskType.WINNER:
			# Win condition logic...
			current_mask_still = win_mask_still
			current_mask_walking = win_mask_walking
			mask_layer.visible = true # Make sure to show it!
			
			var tween = create_tween()
			
			# Add an empty delay of 1 second
			tween.tween_interval(1.0)
			
			# Run the function once the interval finishes
			tween.tween_callback(move_level)
	

		MaskType.BATTERING_RAM:
			# BATTERING_RAM - allows breaking crumbled walls
			is_intangible = false
			properties = ["BREAK_WALL", "PUSH_ROCKS"]
			current_mask_still = battering_mask_still
			current_mask_walking = battering_mask_walking
			mask_layer.visible = true # Make sure to show it!


	# Force a visual update immediately so it doesn't wait for movement
	update_visuals()
	
	print("Mask changed: ", MaskType.keys()[current_mask], " Properties: ", properties)


func update_visuals():
	# 1. Determine if we are moving or still
	var is_moving_visual = is_moving
	
	# 2. Update Base Sprite (Existing logic)
	if is_moving_visual:
		set_sprite_texture(texture_walking)
	else:
		set_sprite_texture(texture_still)
		
	# 3. Update Mask Layer
	if mask_layer.visible and current_mask_still != null:
		if is_moving_visual:
			mask_layer.texture = current_mask_walking
		else:
			mask_layer.texture = current_mask_still
			
		# Match the scale/flipping of the base sprite
		# TextureRect doesn't have flip_h, so we use scale.x
		# Make sure Pivot Offset is centered in Inspector!
		if sprite.flip_h:
			mask_layer.scale.x = -1
		else:
			mask_layer.scale.x = 1
			
				
func has_property(property_name: String) -> bool:
	return properties.has(property_name)

func update_tooltip_state():
	var ui = get_node_or_null("/root/Ingame/InventoryUI")
	if not ui: return

	# 1. Check for Pickup FIRST (Priority)
	var pickup_target = get_mask_at_pos(grid_position)
	
	if pickup_target:
		# We are standing on a mask -> Show Pickup Tooltip
		var m_name = "Unknown"
		var m_desc = ""
		if pickup_target.has_method("get_mask_name"): m_name = pickup_target.get_mask_name()
		if pickup_target.has_method("get_mask_description"): m_desc = pickup_target.get_mask_description()
		
		ui.show_pickup_tooltip(m_name, m_desc)
		return

	# 2. If no pickup, check if we are wearing a mask -> Show Permanent Tooltip
	if current_mask != MaskType.NONE:
		var m_name = get_mask_name(current_mask)
		var m_desc = get_mask_desc(current_mask) # Or fetch a nicer description
		ui.show_perm_tooltip(m_name, m_desc + "\n Press Q to drop")
		return

	# 3. If neither, hide everything
	ui.hide_pickup_tooltip()

# Helper to find mask object at specific grid pos
func get_mask_at_pos(g_pos: Vector2i) -> Node:
	var ingame = get_tree().get_root().get_node("Ingame")
	if not ingame or not ingame.has_node("LevelGenerator/Masks"): return null
	
	for mask_obj in ingame.get_node("LevelGenerator/Masks").get_children():
		var m_pos = grid_manager.world_to_grid(mask_obj.global_position)
		if m_pos == g_pos:
			return mask_obj
	return null

func get_mask_name(type: MaskType) -> String:
	match type:
		MaskType.DIMENSION: return "DIMENSION"
		MaskType.WATER: return "H2O"
		MaskType.WINNER: return "WINNER"
		MaskType.BATTERING_RAM: return "BATTERING RAM"
		MaskType.GOLEM: return "GOLEM"
		_: return "?"
		
func get_mask_desc(type: MaskType) -> String:
	match type:
		MaskType.DIMENSION: return "Press SPACE to toggle pillars!"
		MaskType.WATER: return "Go on, walk on water!"
		MaskType.WINNER: return "YOU'VE WON!"
		MaskType.BATTERING_RAM: return "Smash through crumbling walls and push logs out the way!"
		MaskType.GOLEM: return "Push that rock out the way!"
		_: return "?"
		
	
