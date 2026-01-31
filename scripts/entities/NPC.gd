extends CharacterBody2D
class_name NPC

# --- REFERENCES ---
# We need these to function in the world
@onready var grid_manager: GridManager = get_node("/root/Ingame/GridManager")
@onready var sprite: Sprite2D = $Sprite
@onready var mask_layer: TextureRect = $MaskLayer

# --- ASSETS (Same as Player) ---
var texture_still: Texture2D = preload("res://assets/SpriteStillTransparent.png")
var texture_walking: Texture2D = preload("res://assets/SpriteMovingTransparent.png")

var is_active: bool = false

# Assign these in Inspector just like Player

@export var water_mask_still: Texture2D
@export var water_mask_walking: Texture2D

@export var win_mask_still: Texture2D
@export var win_mask_walking: Texture2D

@export var golem_mask_still: Texture2D
@export var golem_mask_walking: Texture2D

@export var battering_mask_still: Texture2D
@export var battering_mask_walking: Texture2D

func activate(start_grid_pos: Vector2i, start_world_pos: Vector2):
	is_active = true
	visible = true
	
	# --- FIX START: Force initialization if called early ---
	if not mask_layer:
		mask_layer = $MaskLayer
	if not sprite:
		sprite = $Sprite
	if not grid_manager:
		grid_manager = get_node("/root/Ingame/GridManager")
	# --- FIX END ---
	
	grid_position = start_grid_pos
	global_position = start_world_pos
	
	is_moving = false
	current_mask = MaskType.NONE
	update_mask_properties()
	
	# 1. Setup Initial State
	if grid_manager:
		grid_position = grid_manager.world_to_grid(global_position)
		global_position = grid_manager.grid_to_world(grid_position)

	update_mask_properties()
	set_sprite_texture(texture_still)
	
	# 2. Visual Distinction (Ghostly Look)
	$Sprite.modulate = Color(0.3, 0.3, 1.0, 0.3) 

	# 3. Connect to Player Signals
	if not target_player:
		target_player = get_node_or_null("/root/Ingame/Player")
	
	if target_player:
		target_player.player_moved.connect(_on_player_moved)
		target_player.player_interacted.connect(_on_player_interacted)
		
	
func deactivate():
	is_active = false
	visible = false
	global_position = Vector2(-1000, -1000)
	



# --- STATE ---
var grid_position: Vector2i = Vector2i.ZERO
var is_moving: bool = false
var move_duration: float = 0.18 

# Mask Logic (Same Enums)
enum MaskType {NONE, DIMENSION, WATER, WINNER, BATTERING_RAM, GOLEM}
var current_mask: MaskType = MaskType.NONE
var current_mask_still: Texture2D = null
var current_mask_walking: Texture2D = null
var is_intangible: bool = false 
var is_red_mode: bool = true  
var properties: Array[String] = [] 

# --- TARGETING ---
@export var target_player: Player

func _ready():
	if not is_active: return
	
# --- SIGNAL HANDLERS (The "Brain") ---

func _on_player_moved(direction: Vector2i):
	if not is_active: return
	# Try to move in the same direction relative to self
	if not is_moving:
		try_move(direction)

func _on_player_interacted(action_name: String):
	if not is_active: return
	# Mirror actions
	match action_name:
		"pickup":
			try_pickup()
		"drop":
			drop_mask()
		"space":
			if current_mask == MaskType.DIMENSION:
				toggle_phase_mode()

# --- MOVEMENT LOGIC (Copied from Player, removed UI/Input) ---

func try_move(direction: Vector2i):
	if not is_active: return
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
					if rock.is_on_water and not has_property("PUSH_ROCKS"):
						# Rock is a bridge (on water) and we don't have GOLEM
						# Allow walking on it - skip the push logic
						break
						# TODO - bug is that the NPC cannot walk over bridges for some reason
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


	if can_move_to(target_grid_pos):
		grid_position = target_grid_pos
		is_moving = true
		
		# Visuals
		if direction == Vector2i.LEFT: sprite.flip_h = true
		elif direction == Vector2i.RIGHT: sprite.flip_h = false
		update_visuals()

		# Tween
		var target_world_pos = grid_manager.grid_to_world(grid_position)
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "global_position", target_world_pos, move_duration)
		tween.tween_callback(on_movement_finished)

func on_movement_finished():
	if not is_active: return
	is_moving = false
	update_visuals()
	# No UI updates here!

func can_move_to(target_pos: Vector2i) -> bool:
	if not is_active: return false
	
	if not grid_manager.is_valid_position(target_pos): return false
	
	var tile_type = grid_manager.get_tile_type(target_pos)
	match tile_type:
		GridManager.TileType.WALL: return false 
		GridManager.TileType.WATER:
			if has_property("FLOAT"): return true
			return false
		GridManager.TileType.CRUMBLED_WALL:
			if has_property("BREAK_WALL"): return true
			return false 
		GridManager.TileType.EMPTY: return true
		
		# Phase Walls
		GridManager.TileType.RED_WALL:
			if has_property("DIMENSION_SHIFT") and is_red_mode: return true
			return false
		GridManager.TileType.BLUE_WALL:
			if has_property("DIMENSION_SHIFT") and not is_red_mode: return true
			return false
			
	return true

# --- MASK LOGIC (Simplified) ---

func try_pickup():
	var ingame = get_tree().get_root().get_node("Ingame")
	if not ingame: return
	var level_gen = ingame.get_node_or_null("LevelGenerator")
	if not level_gen or not level_gen.has_node("Masks"): return

	for mask_obj in level_gen.get_node("Masks").get_children():
		var mask_grid_pos = grid_manager.world_to_grid(mask_obj.global_position)
		if mask_grid_pos == grid_position:
			# Swap Logic
			if current_mask != MaskType.NONE:
				level_gen.spawn_mask_at(grid_position, current_mask)
			
			wear_mask(mask_obj.mask_type)
			mask_obj.pickup()
			return

func drop_mask():
	if not is_active: return
	if current_mask == MaskType.NONE: return
	var ingame = get_tree().get_root().get_node("Ingame")
	var level_gen = ingame.get_node_or_null("LevelGenerator")
	
	if level_gen and level_gen.has_method("spawn_mask_at"):
		level_gen.spawn_mask_at(grid_position, current_mask)
		remove_mask()

func wear_mask(type):
	current_mask = type
	update_mask_properties()

func remove_mask():
	current_mask = MaskType.NONE
	update_mask_properties()

func toggle_phase_mode():
	is_red_mode = not is_red_mode
	print("NPC Toggled Phase Mode")

func update_mask_properties():
	if not is_active: return
	
	properties.clear()
	is_intangible = false
	current_mask_still = null
	current_mask_walking = null
	mask_layer.visible = false

	match current_mask:
		MaskType.NONE: pass
		MaskType.DIMENSION: 
			properties = ["DIMENSION_SHIFT"]
			current_mask_still = water_mask_still
			current_mask_walking = water_mask_walking
			mask_layer.visible = true
		MaskType.WATER:
			properties = ["FLOAT"]
			current_mask_still = water_mask_still
			current_mask_walking = water_mask_walking
			mask_layer.visible = true
		MaskType.WINNER:
			current_mask_still = win_mask_still
			current_mask_walking = win_mask_walking
			mask_layer.visible = true
		MaskType.BATTERING_RAM: 
			properties = ["BREAK_WALL"]
			current_mask_still = battering_mask_still
			current_mask_walking = battering_mask_walking
			mask_layer.visible = true
		MaskType.GOLEM: 
			properties = ["PUSH_ROCKS"]
			current_mask_still = golem_mask_still
			current_mask_walking = golem_mask_walking
			mask_layer.visible = true

	update_visuals()

# --- VISUALS ---
func update_visuals():
	var is_moving_visual = is_moving
	if is_moving_visual:
		set_sprite_texture(texture_walking)
	else:
		set_sprite_texture(texture_still)
		
	if mask_layer.visible and current_mask_still != null:
		if is_moving_visual:
			mask_layer.texture = current_mask_walking
		else:
			mask_layer.texture = current_mask_still
		
		if sprite.flip_h: mask_layer.scale.x = -1
		else: mask_layer.scale.x = 1

func set_sprite_texture(texture: Texture2D):
	if sprite:
		sprite.texture = texture
		# Assuming you want same scaling logic
		if texture:
			var s = texture.get_size()
			var scale_factor = 180.0 / max(s.x, s.y)
			sprite.scale = Vector2(scale_factor, scale_factor)

func has_property(p: String) -> bool:
	return properties.has(p)
