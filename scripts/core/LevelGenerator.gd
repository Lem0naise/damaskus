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
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	],
		[ # LEVEL 2
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 1, 0, 1, 1, 0, 3, 1, 1, 3, 1, 1, 1, 1], # 3 = Crumbled Wall blocking exit
	[1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, 1],
	[1, 0, 1, 0, 1, 1, 1, 3, 1, 1, 3, 1, 1, 3, 1], # 3 = Crumbled Wall blocking exit
	[1, 0, 1, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 3, 0, 3, 0, 1, 1, 1, 1, 3, 1, 1, 1, 1], # 3 = Weak walls everywhere
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
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
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
],
[ # LEVEL 4 - Rock Bridge Puzzle
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 4, 2, 0, 0, 1, 1, 1, 1, 0, 0, 1], # 4 = Rock, 2 = Water river
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1], # Player starts left side
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 4, 2, 0, 0, 1, 1, 1, 1, 0, 0, 1], # 3 rocks to push into water
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
]
]

var level_masks = [
		[ # LEVEL 1
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
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
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
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
	[0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0], # 4 = RAM (Easy access)
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
	[0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0], # 5 = GOLEM mask, 3 = WINNER mask
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]
]

var level = 0
const MENU_SCENE_PATH: String = "res://main_menu.tscn"

func _ready():
	generate_level(level) # level 1 to start
func next_level():
	level += 1
	if level >2:
		get_tree().change_scene_to_file(MENU_SCENE_PATH)
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

	# 2. Clear Logical Grid Data (The Collisions)
	# We must reset the grid_manager, otherwise invisible walls will remain.
	# We loop through the known grid size (15x9)
	for y in range(9): 
		for x in range(15):
			var grid_pos = Vector2i(x, y)
			# Clear logic for both dimensions (0 and 1) just to be safe
			grid_manager.set_tile(grid_pos, GridManager.TileType.EMPTY, 0)
			grid_manager.set_tile(grid_pos, GridManager.TileType.EMPTY, 1)
	
# --- HELPER FUNCTION ---
func get_neighbours(layout: Array, grid_pos: Vector2i, whatami: int) -> Dictionary:
	var neighbours = { "N": false, "S": false, "E": false, "W": false }
	
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
	
	
func generate_level(level):
	for y in range(level_layouts[level].size()):
		for x in range(level_layouts[level][y].size()):
			var cell_value = level_layouts[level][y][x]
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

	for y in range(level_masks[level].size()):
		for x in range(level_masks[level][y].size()):
			var cell_value = level_masks[level][y][x]
			var grid_pos = Vector2i(x, y)
			var world_pos = grid_manager.grid_to_world(grid_pos)
			
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
				
				
				
					
