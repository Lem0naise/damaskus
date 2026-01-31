extends GameObject
class_name LaserEmitter

@onready var sprite: Sprite2D = $Sprite
@onready var laser_beams_container: Node2D = $LaserBeams

var grid_position: Vector2i
var paired_emitters: Array[LaserEmitter] = []
var active_laser_beams: Array[Line2D] = []

func _ready():
	super._ready()
	if grid_manager:
		grid_position = grid_manager.world_to_grid(global_position)
	# Defer pairing to ensure all emitters are loaded
	call_deferred("find_pair")

func _exit_tree():
	# Clear pairing when being removed
	paired_emitters.clear()
	clear_laser_beams()

func _process(delta):
	update_laser_state()
	check_entity_collision()

func find_pair():
	"""Find ALL aligned emitters to pair with"""
	paired_emitters.clear()

	var level_gen = get_node_or_null("/root/Ingame/LevelGenerator")
	if not level_gen or not level_gen.has_node("LaserEmitters"):
		return

	for other in level_gen.get_node("LaserEmitters").get_children():
		if other == self:
			continue
		if not other is LaserEmitter:
			continue
		# Skip emitters that are being deleted
		if not is_instance_valid(other) or other.is_queued_for_deletion():
			continue

		var other_pos = other.grid_position
		# Check alignment (same X or same Y)
		if grid_position.x == other_pos.x or grid_position.y == other_pos.y:
			paired_emitters.append(other)

func update_laser_state():
	"""Update laser visibility based on line of sight for all paired emitters"""
	# Clear old laser beams
	clear_laser_beams()

	# Create laser beams for each valid paired emitter
	for paired in paired_emitters:
		# Validate paired emitter still exists
		if not paired or not is_instance_valid(paired) or paired.is_queued_for_deletion():
			continue

		# Check line of sight
		if has_line_of_sight(grid_position, paired.grid_position):
			# Create a new laser beam
			var laser_beam = Line2D.new()
			laser_beam.width = 8.0
			laser_beam.default_color = Color(1, 0, 0, 0.8)

			# Update laser visual - draw line from this emitter to paired emitter
			var start_world = grid_manager.grid_to_world(grid_position)
			var end_world = grid_manager.grid_to_world(paired.grid_position)

			# Points are relative to this node's position
			laser_beam.points = [Vector2.ZERO, end_world - start_world]

			# Add to scene
			laser_beams_container.add_child(laser_beam)
			active_laser_beams.append(laser_beam)

func clear_laser_beams():
	"""Remove all active laser beam visuals"""
	for beam in active_laser_beams:
		if is_instance_valid(beam):
			beam.queue_free()
	active_laser_beams.clear()

func has_line_of_sight(from: Vector2i, to: Vector2i) -> bool:
	"""Check if there's a clear path between two grid positions"""
	# Must be aligned (same X or same Y)
	if from.x != to.x and from.y != to.y:
		return false

	# Check each cell between emitters
	var direction = (to - from).sign()
	var current = from + direction

	while current != to:
		if blocks_laser(current):
			return false
		current += direction

	return true

func blocks_laser(pos: Vector2i) -> bool:
	"""Check if a tile blocks laser beams"""
	var tile = grid_manager.get_tile_type(pos)

	# Walls, crumbled walls, and rocks always block
	if tile in [GridManager.TileType.WALL, GridManager.TileType.CRUMBLED_WALL, GridManager.TileType.ROCK]:
		return true

	# Phase columns block when raised (UP state)
	if tile in [GridManager.TileType.RED_WALL, GridManager.TileType.BLUE_WALL]:
		return is_phase_column_raised(pos, tile)

	# Water, quicksand, empty tiles don't block
	return false

func is_phase_column_raised(pos: Vector2i, tile_type: GridManager.TileType) -> bool:
	"""Replicate PhaseWall logic - check if column is raised (blocking)"""
	var player = get_node_or_null("/root/Ingame/Player")
	var npc = get_node_or_null("/root/Ingame/NPC")

	# Check if anyone has DIMENSION_SHIFT property
	var player_has = player and player.has_property("DIMENSION_SHIFT")
	var npc_has = npc and npc.is_active and npc.has_property("DIMENSION_SHIFT")
	var power_active = player_has or npc_has

	# Default: UP (blocking)
	if not power_active:
		return true

	# If power active, check if mode matches wall type
	var is_red_wall = (tile_type == GridManager.TileType.RED_WALL)
	if is_red_wall and grid_manager.is_red_mode:
		return false  # Red walls DOWN in red mode (passable)
	elif not is_red_wall and not grid_manager.is_red_mode:
		return false  # Blue walls DOWN in blue mode (passable)

	return true  # Raised (blocking)

func check_entity_collision():
	"""Check if player or NPC is on any laser path and kill them"""
	if paired_emitters.is_empty():
		return

	var player = get_node_or_null("/root/Ingame/Player")
	var npc = get_node_or_null("/root/Ingame/NPC")

	# Check each laser beam
	for paired in paired_emitters:
		if not paired or not is_instance_valid(paired) or paired.is_queued_for_deletion():
			continue

		# Only check if laser is actually active (has line of sight)
		if not has_line_of_sight(grid_position, paired.grid_position):
			continue

		if player and is_on_laser_path(player.grid_position, paired):
			player.die()
			return  # No need to check further

		if npc and npc.is_active and is_on_laser_path(npc.grid_position, paired):
			npc.die()
			return  # No need to check further

func is_on_laser_path(pos: Vector2i, paired: LaserEmitter) -> bool:
	"""Check if a grid position is on the laser beam between this emitter and a paired emitter"""
	# Don't kill players standing on emitter positions themselves
	if pos == grid_position or pos == paired.grid_position:
		return false

	var min_x = min(grid_position.x, paired.grid_position.x)
	var max_x = max(grid_position.x, paired.grid_position.x)
	var min_y = min(grid_position.y, paired.grid_position.y)
	var max_y = max(grid_position.y, paired.grid_position.y)

	if grid_position.x == paired.grid_position.x:
		# Vertical laser
		return pos.x == grid_position.x and pos.y >= min_y and pos.y <= max_y
	else:
		# Horizontal laser
		return pos.y == grid_position.y and pos.x >= min_x and pos.x <= max_x
