extends CharacterBody2D
class_name NPC

# --- REFERENCES ---
@onready var grid_manager: GridManager = get_node("/root/Ingame/GridManager")
@onready var sprite: Sprite2D = $Sprite
@onready var mask_layer: TextureRect = $MaskLayer

# --- ASSETS ---
var texture_still: Texture2D = preload("res://assets/SpriteStillTransparent.png")
var texture_walking: Texture2D = preload("res://assets/SpriteMovingTransparent.png")

# --- SETTINGS ---
@export var is_active: bool = false
@export var target_player: Player

# Mask Textures (Assign in Inspector)
@export var water_mask_still: Texture2D
@export var water_mask_walking: Texture2D
@export var win_mask_still: Texture2D
@export var win_mask_walking: Texture2D
@export var golem_mask_still: Texture2D
@export var golem_mask_walking: Texture2D
@export var battering_mask_still: Texture2D
@export var battering_mask_walking: Texture2D

@export var damascus_mask_still: Texture2D
@export var damascus_mask_walking: Texture2D


# --- MOVEMENT STATE ---
var grid_position: Vector2i = Vector2i.ZERO
var is_moving: bool = false
var next_move: Vector2i = Vector2i.ZERO # <--- ADDED BUFFER
var move_duration: float = 0.18
var move_tween: Tween

# --- MASK STATE ---
enum MaskType {NONE, DIMENSION, WATER, WINNER, BATTERING_RAM, GOLEM, DAMASCUS}
var current_mask: MaskType = MaskType.NONE
var current_mask_still: Texture2D = null
var current_mask_walking: Texture2D = null
var is_intangible: bool = false
var properties: Array[String] = []

var is_dying: bool = false

func _ready():
	if not is_active:
		hide()
		return

func activate(start_grid_pos: Vector2i, start_world_pos: Vector2):
	is_active = true
	visible = true
	
	# Force init refs
	if not mask_layer: mask_layer = $MaskLayer
	if not sprite: sprite = $Sprite
	if not grid_manager: grid_manager = get_node("/root/Ingame/GridManager")
	
	grid_position = start_grid_pos
	global_position = start_world_pos
	
	reset_state()
	
	$Sprite.modulate = Color(0.3, 0.3, 1.0, 0.6) # Ghostly look

	# Connect signals
	if not target_player:
		target_player = get_node_or_null("/root/Ingame/Player")
	
	if target_player:
		if target_player.player_moved.is_connected(_on_player_moved):
			target_player.player_moved.disconnect(_on_player_moved)
		if target_player.player_interacted.is_connected(_on_player_interacted):
			target_player.player_interacted.disconnect(_on_player_interacted)
			
		target_player.player_moved.connect(_on_player_moved)
		target_player.player_interacted.connect(_on_player_interacted)

func deactivate():
	is_active = false
	visible = false
	global_position = Vector2(-1000, -1000)

# --- SIGNAL HANDLERS ---

func _on_player_moved(direction: Vector2i):
	if not is_active: return
	
	# FIX: Buffer the move if we are busy, just like the Player does
	if is_moving:
		next_move = direction
	else:
		try_move(direction)

func _on_player_interacted(action_name: String):
	if not is_active: return
	match action_name:
		"pickup": try_pickup()
		"drop": drop_mask()
		# Dimension toggle is handled globally via GridManager now

# --- MOVEMENT LOGIC ---

func try_move(direction: Vector2i):
	if not is_active: return
	var target_grid_pos = grid_position + direction
	
	# 1. Rock Logic
	var tile_type = grid_manager.get_tile_type(target_grid_pos)
	if tile_type == GridManager.TileType.ROCK:
		var ingame = get_tree().get_root().get_node("Ingame")
		if ingame and ingame.has_node("LevelGenerator/Rocks"):
			for rock in ingame.get_node("LevelGenerator/Rocks").get_children():
				if rock.has_method("get_grid_position") and rock.get_grid_position() == target_grid_pos:
					if rock.is_on_water:
						break # Walkable bridge
					elif has_property("PUSH_ROCKS"):
						if not rock.on_pushed(direction):
							return # Push blocked
						break # Push success
					else:
						return # Blocked

	# 2. Crumbled Wall Logic
	tile_type = grid_manager.get_tile_type(target_grid_pos)
	if tile_type == GridManager.TileType.CRUMBLED_WALL and has_property("BREAK_WALL"):
		var ingame = get_tree().get_root().get_node("Ingame")
		if ingame and ingame.has_node("LevelGenerator/CrumbledWalls"):
			for wall in ingame.get_node("LevelGenerator/CrumbledWalls").get_children():
				if grid_manager.world_to_grid(wall.global_position) == target_grid_pos:
					wall.queue_free()
					grid_manager.set_tile(target_grid_pos, GridManager.TileType.EMPTY)
					break

	# 3. Execution
	if can_move_to(target_grid_pos):
		grid_position = target_grid_pos
		is_moving = true
		
		if direction == Vector2i.LEFT: sprite.flip_h = true
		elif direction == Vector2i.RIGHT: sprite.flip_h = false
		update_visuals()

		var target_world_pos = grid_manager.grid_to_world(grid_position)
		
		if move_tween: move_tween.kill()
		move_tween = create_tween()
		move_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		move_tween.tween_property(self, "global_position", target_world_pos, move_duration)
		move_tween.tween_callback(on_movement_finished)

func on_movement_finished():
	if not is_active: return
	is_moving = false
	grid_manager.grid_state_changed.emit()
	
	update_visuals()
	
	if grid_manager.is_deadly(grid_position):
		die("Ghost was spiked!")
		return

	# FIX: Execute buffered move immediately to keep up with player
	if next_move != Vector2i.ZERO:
		var buffered_move = next_move
		next_move = Vector2i.ZERO
		try_move(buffered_move)

func can_move_to(target_pos: Vector2i) -> bool:
	if not is_active: return false
	if not grid_manager.is_valid_position(target_pos): return false
	
	# Block if Player is currently on that tile
	if target_player and target_player.grid_position == target_pos:
		return false
	
	var tile_type = grid_manager.get_tile_type(target_pos)
	match tile_type:
		GridManager.TileType.WALL: return false
		GridManager.TileType.LASER_EMITTER: return false # Laser emitters are solid like walls
		GridManager.TileType.WATER:
			return has_property("FLOAT")
		GridManager.TileType.CRUMBLED_WALL:
			return has_property("BREAK_WALL")
		GridManager.TileType.EMPTY: return true
		GridManager.TileType.RED_WALL:
			var anyone_dim = has_property("DIMENSION_SHIFT") or (target_player and target_player.has_property("DIMENSION_SHIFT"))
			return anyone_dim and grid_manager.is_red_mode
		GridManager.TileType.BLUE_WALL:
			var anyone_dim = has_property("DIMENSION_SHIFT") or (target_player and target_player.has_property("DIMENSION_SHIFT"))
			return anyone_dim and not grid_manager.is_red_mode
			
	return true

# --- STATE RESET & HELPERS ---

func reset_state():
	if move_tween: move_tween.kill()
	is_moving = false
	next_move = Vector2i.ZERO
	current_mask = MaskType.NONE
	update_mask_properties()
	set_sprite_texture(texture_still)
	is_dying = false

func die(reason: String = "Partner died!", delay: float = 0.0):
	if is_dying: return
	is_dying = true
	
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	# TODO flash red
	remove_mask()
	var ingame = get_tree().get_root().get_node("Ingame")
	if ingame and ingame.has_method("trigger_death"):
		ingame.trigger_death(reason)
	elif ingame and ingame.has_node("IngameManager"):
		ingame.get_node("IngameManager").trigger_death(reason)

func try_pickup():
	var ingame = get_tree().get_root().get_node("Ingame")
	if not ingame: return
	var level_gen = ingame.get_node_or_null("LevelGenerator")
	if not level_gen or not level_gen.has_node("Masks"): return

	for mask_obj in level_gen.get_node("Masks").get_children():
		if mask_obj.get("is_picked_up"):
			continue
			
		var mask_grid_pos = grid_manager.world_to_grid(mask_obj.global_position)
		if mask_grid_pos == grid_position:
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
	if not is_active: return
	current_mask = MaskType.NONE
	update_mask_properties()

func update_mask_properties():
	if not is_active: return
	properties.clear()
	is_intangible = false
	current_mask_still = null
	current_mask_walking = null
	if mask_layer: mask_layer.visible = false

	match current_mask:
		MaskType.NONE: pass
		MaskType.DIMENSION:
			properties = ["DIMENSION_SHIFT"]
			current_mask_still = golem_mask_still # Placeholder?
			current_mask_walking = golem_mask_walking
			if mask_layer: mask_layer.visible = true
		MaskType.WATER:
			properties = ["FLOAT"]
			current_mask_still = water_mask_still
			current_mask_walking = water_mask_walking
			if mask_layer: mask_layer.visible = true
		MaskType.WINNER:
			current_mask_still = win_mask_still
			current_mask_walking = win_mask_walking
			if mask_layer: mask_layer.visible = true
		MaskType.BATTERING_RAM:
			properties = ["BREAK_WALL", "PUSH_ROCKS"]
			current_mask_still = battering_mask_still
			current_mask_walking = battering_mask_walking
			if mask_layer: mask_layer.visible = true
		MaskType.GOLEM:
			properties = ["PUSH_ROCKS"]
			current_mask_still = golem_mask_still
			current_mask_walking = golem_mask_walking
			if mask_layer: mask_layer.visible = true
		MaskType.DAMASCUS:
			properties = ["BLOCK_LASERS"]
			current_mask_still = damascus_mask_still
			current_mask_walking = damascus_mask_walking
			if mask_layer: mask_layer.visible = true
		MaskType.DAMASCUS:
			properties = ["BLOCK_LASERS"]
			current_mask_still = damascus_mask_still
			current_mask_walking = damascus_mask_walking
			if mask_layer: mask_layer.visible = true

	update_visuals()

func update_visuals():
	var is_moving_visual = is_moving
	if is_moving_visual:
		set_sprite_texture(texture_walking)
	else:
		set_sprite_texture(texture_still)
		
	if mask_layer and mask_layer.visible and current_mask_still != null:
		if is_moving_visual:
			mask_layer.texture = current_mask_walking
		else:
			mask_layer.texture = current_mask_still
		
		if sprite.flip_h: mask_layer.scale.x = -1
		else: mask_layer.scale.x = 1

func set_sprite_texture(texture: Texture2D):
	if sprite:
		sprite.texture = texture
		if texture:
			var s = texture.get_size()
			var scale_factor = 180.0 / max(s.x, s.y)
			sprite.scale = Vector2(scale_factor, scale_factor)

func has_property(p: String) -> bool:
	return properties.has(p)
