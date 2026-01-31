extends Node2D

@onready var grid_manager: GridManager = %GridManager # Make sure GridManager is accessible
@onready var walls_container = $Walls
@onready var water_container = $Water
@onready var masks_container = $Masks

# Prefabs (Assign these in Inspector)
@export var wall_scene: PackedScene
@export var water_scene: PackedScene
@export var mask_scene: PackedScene
@export var crumbled_wall_scene: PackedScene
@export var rock_scene: PackedScene = preload("res://scenes/objects/rock.tscn")
@export var red_wall_scene: PackedScene = preload("res://scenes/objects/red_wall.tscn")
@export var blue_wall_scene: PackedScene = preload("res://scenes/objects/blue_wall.tscn")

# 0 = Empty, 1 = Wall, 2 = Water
# 15 Width x 9 Height
# user spawns at top right
var level_layouts = [
		[ # LEVEL 1
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 1, 0, 0, 2, 2, 2, 0, 0, 1],
		[1, 0, 0, 1, 1, 0, 1, 0, 0, 2, 0, 2, 0, 0, 1],
		[1, 0, 0, 1, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 1],
		[1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1],
		[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	],
		[ # LEVEL 2
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 3, 1, 1, 1, 1], # 3 = Crumbled Wall blocking exit
	[1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 3, 0, 0, 3, 1],
	[1, 0, 1, 0, 1, 1, 1, 3, 1, 1, 3, 1, 1, 3, 1], # 3 = Crumbled Wall blocking exit
	[1, 0, 1, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 3, 0, 3, 0, 1, 1, 1, 1, 3, 1, 1, 1, 1], # 3 = Weak walls everywhere
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
],
[ # LEVEL 3
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
	[1, 0, 1, 1, 3, 3, 1, 0, 1, 2, 2, 2, 2, 0, 1], # 3 = Wall blocking Water Mask
	[1, 0, 1, 0, 0, 0, 1, 0, 1, 2, 0, 0, 2, 0, 1], # 2 = The Moat
	[1, 0, 1, 0, 0, 0, 1, 0, 1, 2, 0, 0, 2, 0, 1],
	[1, 0, 1, 1, 1, 1, 1, 0, 1, 2, 2, 2, 2, 0, 1],
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
],
[ # LEVEL 4 - Rock Bridge Puzzle
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 0, 2, 4, 0, 1, 1, 1, 1, 0, 0, 1], # 4 = Rock, 2 = Water river
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 0, 2, 4, 0, 0, 0, 0, 0, 0, 0, 1], # Player starts left side
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 0, 2, 4, 0, 1, 1, 1, 1, 0, 0, 1], # 3 rocks to push into water
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
],
[ # LEVEL 5 - Phase Maze
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 5, 0, 6, 0, 5, 0, 6, 0, 0, 0, 0, 0, 1],
	[1, 0, 5, 0, 6, 0, 5, 0, 6, 1, 1, 1, 1, 0, 1],
	[1, 0, 5, 0, 6, 0, 5, 0, 6, 0, 0, 0, 0, 0, 1],
	[1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1],
	[1, 0, 0, 0, 0, 6, 0, 0, 0, 5, 0, 0, 0, 0, 1],
	[1, 0, 1, 1, 1, 6, 1, 1, 1, 5, 1, 1, 1, 0, 1],
	[1, 0, 0, 0, 0, 6, 0, 0, 0, 5, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
],
[ # Level 6 - From web editor, multiple
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 3, 3, 3, 1],
	[1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 3, 0, 3, 1],
	[1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 2, 3, 3, 3, 1],
	[1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 2, 2, 2, 1],
	[1, 2, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1],
	[1, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
]
]

var level_masks = [
		[ # LEVEL 1
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	],
	[ # LEVEL 2
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0], # 4 = RAM, 3 = WINNER
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
],
[ # LEVEL 3
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, -1, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0], # 4 = RAM (Easy access)
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0], # 1 = WATER (Trapped), 3 = WINNER (Across moat)
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
],
[ # LEVEL 4 - Rock Bridge Puzzle Masks
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0], # 5 = GOLEM mask, 3 = WINNER mask
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]
,
[ # LEVEL 5 - Phase Maze Masks
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 2, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0], # 3 = WINNER
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
],
[ # Level 6 - From editor
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, -1, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 5, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],

]
]

var level = 0
const MENU_SCENE_PATH: String = "res://main_menu.tscn"
const WIN_SCENE_PATH: String = "res://win.tscn"

func _ready():
	generate_level(level) # level 1 to start
func next_level():
	level += 1
	if level > 5:
		get_tree().change_scene_to_file(WIN_SCENE_PATH)
	else:
		clear_level()
		generate_level(level)
func clear_level():
	# 1. Clear Visual Nodes (The Sprites)
	for child in walls_container.get_children():
		child.queue_free()
		
	for child in water_container.get_children():
		child.queue_free()
		
	for child in masks_container.get_children():
		child.queue_free()
		
	if has_node("CrumbledWalls"):
		for child in get_node("CrumbledWalls").get_children():
			child.queue_free()

	if has_node("Rocks"):
		for child in get_node("Rocks").get_children():
			child.queue_free()

	if has_node("RedWalls"):
		for child in get_node("RedWalls").get_children():
			child.queue_free()

	if has_node("BlueWalls"):
		for child in get_node("BlueWalls").get_children():
			child.queue_free()

	# 2. Clear Logical Grid Data (The Collisions)
	# We must reset the grid_manager, otherwise invisible walls will remain.
	# We loop through the known grid size (15x9)
	for y in range(9):
		for x in range(15):
			var grid_pos = Vector2i(x, y)
			grid_manager.set_tile(grid_pos, GridManager.TileType.EMPTY)
	
# --- HELPER FUNCTION ---
func get_neighbours(layout: Array, grid_pos: Vector2i, whatami: int) -> Dictionary:
	var neighbours = {"N": false, "S": false, "E": false, "W": false}
	
	var x = grid_pos.x
	var y = grid_pos.y
	
	var is_me = func(nx, ny):
		if ny < 0 or ny >= layout.size(): return false
		if nx < 0 or nx >= layout[ny].size(): return false
		return layout[ny][nx] == whatami

	neighbours["N"] = is_me.call(x, y - 1)
	neighbours["S"] = is_me.call(x, y + 1)
	neighbours["E"] = is_me.call(x + 1, y)
	neighbours["W"] = is_me.call(x - 1, y)
	
	return neighbours
	
	
func generate_level(level_idx):
	
	
	var npc = get_node_or_null("/root/Ingame/NPC")
	if npc:
		npc.deactivate()
				
	for y in range(level_layouts[level_idx].size()):
		for x in range(level_layouts[level_idx][y].size()):
			var cell_value = level_layouts[level_idx][y][x]
			var grid_pos = Vector2i(x, y)
			var world_pos = grid_manager.grid_to_world(grid_pos)
			
			if cell_value == 1: # WALL
				var wall = wall_scene.instantiate()
				# TODO make a corner wall
				wall.position = world_pos
				walls_container.add_child(wall)
				# Register to GridManager
				grid_manager.set_tile(grid_pos, GridManager.TileType.WALL)
				
				
				# Check neighbors to determine texture
				var neighbours = get_neighbours(level_layouts[level], grid_pos, 1)
				# We defer this slightly or call immediate if script is ready
				if wall.has_method("update_appearance"):
					wall.update_appearance(neighbours)


			elif cell_value == 2: # WATER
				var water = water_scene.instantiate()
				water.position = world_pos
				water_container.add_child(water)
				grid_manager.set_tile(grid_pos, GridManager.TileType.WATER)
				
				
				# Check neighbors to determine texture
				var neighbours = get_neighbours(level_layouts[level], grid_pos, 2)
				# We defer this slightly or call immediate if script is ready
				if water.has_method("update_appearance"):
					water.update_appearance(neighbours)


			elif cell_value == 3: # CRUMBLED WALL
				var crumbled_wall = crumbled_wall_scene.instantiate()
				crumbled_wall.position = world_pos

				# Create a dedicated container if it doesn't exist, or just use walls for now but track them?
				# Actually, the player needs to find them by group/container to queue_free them.
				# Let's add a "CrumbledWalls" container dynamically if not present, or better yet, assume structure.
				# For now, let's create a node called "CrumbledWalls" in _ready or just add here.
				if not has_node("CrumbledWalls"):
					var node = Node2D.new()
					node.name = "CrumbledWalls"
					add_child(node)

				get_node("CrumbledWalls").add_child(crumbled_wall)

				# Register to GridManager
				grid_manager.set_tile(grid_pos, GridManager.TileType.CRUMBLED_WALL)

			elif cell_value == 4: # ROCK
				var rock = rock_scene.instantiate()
				rock.position = world_pos

				if not has_node("Rocks"):
					var node = Node2D.new()
					node.name = "Rocks"
					add_child(node)

				get_node("Rocks").add_child(rock)
				grid_manager.set_tile(grid_pos, GridManager.TileType.ROCK)

			elif cell_value == 5: # RED WALL
				var red_wall = red_wall_scene.instantiate()
				red_wall.position = world_pos

				if not has_node("RedWalls"):
					var node = Node2D.new()
					node.name = "RedWalls"
					add_child(node)

				get_node("RedWalls").add_child(red_wall)
				grid_manager.set_tile(grid_pos, GridManager.TileType.RED_WALL)

			elif cell_value == 6: # BLUE WALL
				var blue_wall = blue_wall_scene.instantiate()
				blue_wall.position = world_pos

				if not has_node("BlueWalls"):
					var node = Node2D.new()
					node.name = "BlueWalls"
					add_child(node)

				get_node("BlueWalls").add_child(blue_wall)
				grid_manager.set_tile(grid_pos, GridManager.TileType.BLUE_WALL)

	for y in range(level_masks[level].size()):
		for x in range(level_masks[level][y].size()):
			var cell_value = level_masks[level][y][x]
			var grid_pos = Vector2i(x, y)
			var world_pos = grid_manager.grid_to_world(grid_pos)
			
			if cell_value == -1: # player
				var player = get_node_or_null("/root/Ingame/Player")
				if player:
					player.show()
					# Directly set position and internal grid reference
					player.global_position = world_pos
					player.grid_position = grid_pos
					# Reset any movement state
					player.is_moving = false
					player.next_move = Vector2i.ZERO
					
			if cell_value == -2: # critter
				if npc:
					npc.activate(grid_pos, world_pos)
					npc.is_moving = false
					
			if cell_value > 0:
				var mask = mask_scene.instantiate()
				mask.position = world_pos

				if cell_value == 1: # WATER FLOAT MASK
					mask.mask_type = Mask.MaskType.WATER
				if cell_value == 2:
					mask.mask_type = Mask.MaskType.DIMENSION


				if cell_value == 3: # WINNING MASK
					mask.mask_type = Mask.MaskType.WINNER

				if cell_value == 4: # BATTERING RAM MASK
					mask.mask_type = Mask.MaskType.BATTERING_RAM

				if cell_value == 5: # GOLEM MASK
					mask.mask_type = Mask.MaskType.GOLEM

				masks_container.add_child(mask)


# --- NEW HELPER FOR SWAPPING MASKS ---
func spawn_mask_at(grid_pos: Vector2i, mask_type_id: int):
	if not mask_scene:
		print("Error: mask_scene is missing in LevelGenerator inspector!")
		return

	# 1. Create the mask
	var mask = mask_scene.instantiate()
	
	# 2. Position it
	mask.position = grid_manager.grid_to_world(grid_pos)
	
	# 3. Assign Type (Make sure your Mask.gd has this variable)
	mask.mask_type = mask_type_id
	
	# 4. Add to the scene tree
	masks_container.add_child(mask)
	
	print("Dropped mask ", mask_type_id, " at ", grid_pos)
