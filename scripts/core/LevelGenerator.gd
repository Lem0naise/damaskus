extends Node2D

@onready var grid_manager: GridManager = %GridManager # Make sure GridManager is accessible
@onready var walls_container = $Walls
@onready var water_container = $Water
@onready var masks_container = $Masks

# Prefabs (Assign these in Inspector)
@export var wall_scene: PackedScene
@export var water_scene: PackedScene
@export var mask_scene: PackedScene

# 0 = Empty, 1 = Wall, 2 = Water
# 15 Width x 9 Height
var level_1_layout = [
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 0, 0, 1, 0, 0, 2, 2, 2, 0, 0, 1],
	[1, 0, 0, 1, 1, 0, 1, 0, 0, 2, 0, 2, 0, 0, 1],
	[1, 0, 0, 1, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 1],
	[1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
]
var level_1_masks = [
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 3, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]

func _ready():
	generate_level()

func generate_level():
	for y in range(level_1_layout.size()):
		for x in range(level_1_layout[y].size()):
			var cell_value = level_1_layout[y][x]
			var grid_pos = Vector2i(x, y)
			var world_pos = grid_manager.grid_to_world(grid_pos)
			
			if cell_value == 1: # WALL
				var wall = wall_scene.instantiate()
				wall.position = world_pos
				walls_container.add_child(wall)
				# Register to GridManager
				grid_manager.set_tile(grid_pos, GridManager.TileType.WALL)
				
			elif cell_value == 2: # WATER
				var water = water_scene.instantiate()
				water.position = world_pos
				water_container.add_child(water)
				# Register to GridManager
				grid_manager.set_tile(grid_pos, GridManager.TileType.WATER)
				
	for y in range(level_1_masks.size()):
		for x in range(level_1_masks[y].size()):
			var cell_value = level_1_masks[y][x]
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
					
				masks_container.add_child(mask)
				
				
				
					
