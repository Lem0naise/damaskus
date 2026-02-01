extends GameObject
class_name LaserEmitter

@onready var sprite: Sprite2D = $Sprite
@onready var laser_beams_container: Node2D = $LaserBeams

@export var beam_texture: PackedScene

var grid_position: Vector2i
var paired_emitters: Array[LaserEmitter] = []
var beam_sprites_map: Dictionary = {}

func _ready():
	super._ready()
	if grid_manager:
		grid_position = grid_manager.world_to_grid(global_position)
		if not grid_manager.is_connected("grid_state_changed", _on_grid_update):
			grid_manager.grid_state_changed.connect(_on_grid_update)
	call_deferred("find_pair")

func _exit_tree():
	_clear_all_beams()

func _on_grid_update():
	# --- FIX 1: STOP ZOMBIE EXECUTION ---
	if is_queued_for_deletion():
		return
	# ------------------------------------
	
	update_laser_visibility()
	check_entity_collision()

func _clear_all_beams():
	for pair in beam_sprites_map:
		for s in beam_sprites_map[pair]:
			if is_instance_valid(s): s.queue_free()
	beam_sprites_map.clear()
	paired_emitters.clear()

func find_pair():
	_clear_all_beams()

	var level_gen = get_node_or_null("/root/Ingame/LevelGenerator")
	if not level_gen or not level_gen.has_node("LaserEmitters"):
		if get_parent().name == "LaserEmitters": pass
		else: return

	var all_emitters = level_gen.get_node("LaserEmitters").get_children()
	
	for other in all_emitters:
		if other == self: continue
		if not other is LaserEmitter: continue
		
		# Check if other is valid AND not dying
		if not is_instance_valid(other) or other.is_queued_for_deletion(): continue

		var other_pos = other.grid_position
		
		if grid_position.x == other_pos.x or grid_position.y == other_pos.y:
			if self.get_instance_id() < other.get_instance_id():
				paired_emitters.append(other)
				_generate_beams_for_pair(other)
	
	update_laser_visibility()

func _generate_beams_for_pair(paired: LaserEmitter):
	var start = grid_position
	var end = paired.grid_position
	var direction = (end - start).sign()
	var current = start + direction
	
	var sprites: Array[Node2D] = []
	
	while current != end:
		if not beam_texture: break

		var beam_sprite = beam_texture.instantiate()
		var global_pos = grid_manager.grid_to_world(current)
		beam_sprite.position = to_local(global_pos)
		
		if direction.y != 0:
			beam_sprite.rotation_degrees = 90
		else:
			beam_sprite.rotation_degrees = 0
			
		beam_sprite.visible = false
		
		laser_beams_container.add_child(beam_sprite)
		sprites.append(beam_sprite)
		current += direction
		
	beam_sprites_map[paired] = sprites

func update_laser_visibility():
	for paired in paired_emitters:
		# --- FIX 2: IGNORE DYING PAIRS ---
		if not is_instance_valid(paired) or paired.is_queued_for_deletion():
			continue
		# ---------------------------------
		
		if not paired in beam_sprites_map: continue
		
		var sprites = beam_sprites_map[paired]
		var is_active = is_path_complete(grid_position, paired.grid_position)
		
		for beam_sprite in sprites:
			beam_sprite.visible = is_active

func check_entity_collision():
	var player = get_node_or_null("/root/Ingame/Player")
	var npc = get_node_or_null("/root/Ingame/NPC")
	
	if not player and not npc: return

	for paired in paired_emitters:
		# --- FIX 2 REPEATED: IGNORE DYING PAIRS ---
		if not is_instance_valid(paired) or paired.is_queued_for_deletion():
			continue
		# ------------------------------------------
		
		if not is_path_complete(grid_position, paired.grid_position):
			continue
		
		var start = grid_position
		var end = paired.grid_position
		var direction = (end - start).sign()
		var current = start + direction
		
		while current != end:
			if player and player.grid_position == current:
				player.die("You were fried!")
			if npc and npc.is_active and npc.grid_position == current:
				npc.die("Ghost was fried!")
				
			current += direction

func is_path_complete(start: Vector2i, end: Vector2i) -> bool:
	if start.x != end.x and start.y != end.y: return false
	
	var direction = (end - start).sign()
	if direction == Vector2i.ZERO: return true

	var current = start + direction
	var safety_counter = 0
	
	while current != end:
		safety_counter += 1
		if safety_counter > 50: return false
			
		if blocks_laser(current): return false
		current += direction
		
	return true

func blocks_laser(pos: Vector2i) -> bool:
	var tile = grid_manager.get_tile_type(pos)
	
	if tile in [GridManager.TileType.WALL, GridManager.TileType.CRUMBLED_WALL, GridManager.TileType.ROCK, GridManager.TileType.LASER_EMITTER]:
		return true

	if tile in [GridManager.TileType.RED_WALL, GridManager.TileType.BLUE_WALL]:
		return is_phase_column_raised(pos, tile)
	
	# Check for entities blocking the laser (DAMASCUS mask)
	if is_entity_blocking(pos):
		return true

	return false

func is_entity_blocking(pos: Vector2i) -> bool:
	var player = get_node_or_null("/root/Ingame/Player")
	var npc = get_node_or_null("/root/Ingame/NPC")
	
	if player and player.grid_position == pos and player.has_property("BLOCK_LASERS"):
		return true
		
	if npc and npc.is_active and npc.grid_position == pos and npc.has_property("BLOCK_LASERS"):
		return true
		
	return false

func is_phase_column_raised(pos: Vector2i, tile_type: GridManager.TileType) -> bool:
	var player = get_node_or_null("/root/Ingame/Player")
	var npc = get_node_or_null("/root/Ingame/NPC")

	var player_has = player and player.has_property("DIMENSION_SHIFT")
	var npc_has = npc and npc.is_active and npc.has_property("DIMENSION_SHIFT")
	var power_active = player_has or npc_has

	if not power_active: return true

	var is_red_wall = (tile_type == GridManager.TileType.RED_WALL)
	if is_red_wall and grid_manager.is_red_mode: return false
	elif not is_red_wall and not grid_manager.is_red_mode: return false

	return true
