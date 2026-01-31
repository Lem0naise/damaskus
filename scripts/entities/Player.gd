extends CharacterBody2D
class_name Player

# --- References ---
@onready var grid_manager: GridManager = get_node("/root/Ingame/GridManager")
@onready var sprite: Sprite2D = $Sprite
# Make sure your TextureRect is named "MaskLayer" or update this path
@onready var mask_layer: TextureRect = $MaskLayer 

const MENU_SCENE_PATH: String = "res://main_menu.tscn"

# --- ASSETS ---
# Base Character (Always the same)
@export var tex_base_still: Texture2D 
@export var tex_base_walk: Texture2D

# Water Mask Overlays
@export var tex_spirit_still: Texture2D
@export var tex_spirit_walk: Texture2D 

# --- VISUAL STATE ---
# What texture should the mask show right now? (null if no mask)
var active_mask_still: Texture2D = null
var active_mask_walk: Texture2D = null

# Sprite size
const SPRITE_SIZE = 180.0 

# Movement Configuration
var grid_position: Vector2i = Vector2i.ZERO
var is_moving: bool = false
var move_duration: float = 0.18 

# Input buffering
var next_move: Vector2i = Vector2i.ZERO 
var move_cooldown: float = 0.0
const HELD_KEY_DELAY = 0.12 
const HELD_KEY_INITIAL_DELAY = 0.25 
var held_key_timer: float = 0.0
var last_held_direction: Vector2i = Vector2i.ZERO

# Mask system
enum MaskType { NONE, DIMENSION, WATER, WINNER, BATTERING_RAM, GOLEM }
var current_mask: MaskType = MaskType.NONE
var inventory: Array[MaskType] = [] 
var is_intangible: bool = false 
var current_dimension: int = 0
const NUM_DIMENSIONS: int = 2 
var properties: Array[String] = [] 

func _ready():
	# Setup Base Visuals
	sprite.texture = tex_base_still
	mask_layer.visible = false # Hide mask initially

	# Snap to grid
	if grid_manager:
		grid_position = grid_manager.world_to_grid(global_position)
		global_position = grid_manager.grid_to_world(grid_position)

	update_mask_properties()

	# Sync Objects
	var ingame = get_tree().get_root().get_node("Ingame")
	if ingame:
		for group in ["Walls", "Water", "Rocks"]:
			if ingame.has_node(group):
				for obj in ingame.get_node(group).get_children():
					if obj.has_method("update_dimension_visibility"):
						obj.update_dimension_visibility(current_dimension)
	
	update_inventory_ui()

func _process(delta):
	if move_cooldown > 0: move_cooldown -= delta
	if held_key_timer > 0: held_key_timer -= delta

	handle_input()

	if Input.is_action_just_pressed("ui_accept"): 
		if current_mask == MaskType.DIMENSION: switch_dimension()

	if Input.is_action_just_pressed("pickup"): try_pickup()

	if not is_moving and next_move != Vector2i.ZERO and move_cooldown <= 0:
		var buffered_move = next_move
		next_move = Vector2i.ZERO
		try_move(buffered_move)

func switch_dimension():
	current_dimension = (current_dimension + 1) % NUM_DIMENSIONS
	print("Switched to dimension ", current_dimension)
	var ingame = get_tree().get_root().get_node("Ingame")
	if ingame:
		for group in ["Walls", "Water", "Rocks"]:
			if ingame.has_node(group):
				for obj in ingame.get_node(group).get_children():
					if obj.has_method("update_dimension_visibility"):
						obj.update_dimension_visibility(current_dimension)

func try_pickup():
	var ingame = get_tree().get_root().get_node("Ingame")
	if not ingame or not ingame.has_node("LevelGenerator/Masks"): return

	for mask_obj in ingame.get_node("LevelGenerator/Masks").get_children():
		if mask_obj.has_method("pickup"):
			var mask_grid_pos = grid_manager.world_to_grid(mask_obj.global_position)
			if mask_grid_pos == grid_position:
				var mask_type = mask_obj.mask_type
				if not inventory.has(mask_type):
					inventory.append(mask_type)
					print("Picked up ", MaskType.keys()[mask_type])
					mask_obj.pickup()
					update_inventory_ui()
					var ui = get_node_or_null("/root/Ingame/InventoryUI")
					if ui: ui.hide_pickup_tooltip()
				return

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
			equip_mask_at_index(event.keycode - KEY_1)

func update_inventory_ui():
	var ui = get_node_or_null("/root/Ingame/InventoryUI")
	if ui and ui.has_method("update_inventory"):
		ui.update_inventory(inventory, current_mask)

func handle_input():
	var input_dir = Vector2i.ZERO
	var is_just_pressed = false

	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_d"):
		input_dir = Vector2i.RIGHT; is_just_pressed = true; held_key_timer = HELD_KEY_INITIAL_DELAY
	elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_a"):
		input_dir = Vector2i.LEFT; is_just_pressed = true; held_key_timer = HELD_KEY_INITIAL_DELAY
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_s"):
		input_dir = Vector2i.DOWN; is_just_pressed = true; held_key_timer = HELD_KEY_INITIAL_DELAY
	elif Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_w"):
		input_dir = Vector2i.UP; is_just_pressed = true; held_key_timer = HELD_KEY_INITIAL_DELAY

	if not is_just_pressed and not is_moving and move_cooldown <= 0 and held_key_timer <= 0:
		if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_d"): input_dir = Vector2i.RIGHT
		elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_a"): input_dir = Vector2i.LEFT
		elif Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_s"): input_dir = Vector2i.DOWN
		elif Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_w"): input_dir = Vector2i.UP
		else: held_key_timer = 0

	if input_dir != Vector2i.ZERO:
		if is_moving: next_move = input_dir
		elif move_cooldown <= 0: try_move(input_dir)

func try_move(direction: Vector2i):
	var target_grid_pos = grid_position + direction

	# Check if moving into a ROCK
	var tile_type = grid_manager.get_tile_type(target_grid_pos, current_dimension)
	if tile_type == GridManager.TileType.ROCK:
		# Find the rock to check if it's on water
		var ingame = get_tree().get_root().get_node("Ingame")
		if ingame and ingame.has_node("LevelGenerator/Rocks"):
			for rock in ingame.get_node("LevelGenerator/Rocks").get_children():
				if rock.has_method("get_grid_position") and rock.get_grid_position() == target_grid_pos:
					# Found the rock at target position
					if rock.is_on_water and not has_property("PUSH_ROCKS"):
						# Rock is a bridge (on water) and we don't have GOLEM
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
	tile_type = grid_manager.get_tile_type(target_grid_pos, current_dimension)
	if tile_type == GridManager.TileType.CRUMBLED_WALL and has_property("BREAK_WALL"):
		var ingame = get_tree().get_root().get_node("Ingame")
		if ingame and ingame.has_node("LevelGenerator/CrumbledWalls"):
			for wall in ingame.get_node("LevelGenerator/CrumbledWalls").get_children():
				if grid_manager.world_to_grid(wall.global_position) == target_grid_pos:
					wall.queue_free()
					grid_manager.set_tile(target_grid_pos, GridManager.TileType.EMPTY, current_dimension)
					break

	if can_move_to(target_grid_pos):
		grid_position = target_grid_pos
		is_moving = true
		
		# --- UPDATE VISUALS FOR WALK ---
		update_visuals(true) # true = walking

		# Flip horizontally
		if direction == Vector2i.LEFT:
			sprite.flip_h = true
			# TextureRect doesn't have flip_h, so we flip scale.x
			# NOTE: Ensure Pivot Offset is set to center in Inspector!
			mask_layer.scale.x = -1 
		elif direction == Vector2i.RIGHT:
			sprite.flip_h = false
			mask_layer.scale.x = 1

		move_cooldown = HELD_KEY_DELAY
		
		var target_world_pos = grid_manager.grid_to_world(grid_position)
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "global_position", target_world_pos, move_duration)
		tween.tween_callback(on_movement_finished)

func on_movement_finished():
	is_moving = false
	# --- UPDATE VISUALS FOR IDLE ---
	update_visuals(false) # false = still

	check_for_mask_tooltip()

	if next_move != Vector2i.ZERO:
		var buffered_move = next_move
		next_move = Vector2i.ZERO
		try_move(buffered_move)

# --- NEW VISUAL MANAGER --# --- NEW VISUAL MANAGER ---
func update_visuals(is_walking: bool):
	# 1. Update Base Player (Always same)
	if is_walking:
		sprite.texture = tex_base_walk
	else:
		sprite.texture = tex_base_still
	
	# 2. Update Mask Overlay
	if current_mask != MaskType.NONE and active_mask_still:
		mask_layer.visible = true
		if is_walking:
			mask_layer.texture = active_mask_walk
		else:
			mask_layer.texture = active_mask_still
	else:
		mask_layer.visible = false
		
func can_move_to(target_pos: Vector2i) -> bool:
	if not grid_manager.is_valid_position(target_pos): return false
	if is_intangible: return true

	var tile_type = grid_manager.get_tile_type(target_pos, current_dimension)
	match tile_type:
		GridManager.TileType.WALL:
			return false # Always blocked by walls

		GridManager.TileType.WATER:
			if has_property("FLOAT"): return true
			return false
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
							return true  # Can walk on rock-on-water
						return false  # Can't walk through rocks not on water
			return false

		GridManager.TileType.EMPTY:
			return true # Free to move

	return true

func wear_mask(mask_type: MaskType):
	current_mask = mask_type
	update_mask_properties()
	update_inventory_ui()

func remove_mask():
	current_mask = MaskType.NONE
	update_mask_properties()
	update_inventory_ui()

func update_mask_properties():
	properties.clear()
	is_intangible = false
	
	# Reset Mask Visuals
	active_mask_still = null
	active_mask_walk = null

	match current_mask:
		MaskType.NONE:
			is_intangible = false
			properties = []

		MaskType.DIMENSION:
			is_intangible = false
			properties = ["DIMENSION_SHIFT"]
			# Set Dimension mask texture here if you have one

		MaskType.WATER:
			is_intangible = false
			properties = ["FLOAT"]
			# --- SET WATER SPIRIT TEXTURES ---
			active_mask_still = tex_spirit_still
			active_mask_walk = tex_spirit_walk
		
		MaskType.WINNER: 
			get_parent().next_level()
			get_tree().change_scene_to_file(MENU_SCENE_PATH)

		MaskType.BATTERING_RAM:
			is_intangible = false
			properties = ["BREAK_WALL"]

		MaskType.GOLEM:
			# GOLEM - allows pushing rocks
			is_intangible = false
			properties = ["PUSH_ROCKS"]

	print("Mask changed: ", MaskType.keys()[current_mask], " Properties: ", properties)

func has_property(property_name: String) -> bool:
	return properties.has(property_name)

func check_for_mask_tooltip():
	var ingame = get_tree().get_root().get_node("Ingame")
	if not ingame or not ingame.has_node("LevelGenerator/Masks"): return
		
	var found_mask = false
	for mask_obj in ingame.get_node("LevelGenerator/Masks").get_children():
		var mask_grid_pos = grid_manager.world_to_grid(mask_obj.global_position)
		if mask_grid_pos == grid_position:
			found_mask = true
			var ui = get_node_or_null("/root/Ingame/InventoryUI")
			if ui and ui.has_method("show_pickup_tooltip"):
				var mask_name = "Unknown"
				var mask_desc = ""
				if mask_obj.has_method("get_mask_name"): mask_name = mask_obj.get_mask_name()
				if mask_obj.has_method("get_mask_description"): mask_desc = mask_obj.get_mask_description()
				ui.show_pickup_tooltip(mask_name, mask_desc)
			break
	
	if not found_mask:
		var ui = get_node_or_null("/root/Ingame/InventoryUI")
		if ui and ui.has_method("hide_pickup_tooltip"): ui.hide_pickup_tooltip()
