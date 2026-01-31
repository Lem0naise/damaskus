@tool
extends GameObject
class_name Water

# --- Visual Configuration ---
# Assign these in the Inspector!
@export var tex_center: Texture2D # Surrounded by water on all sides
@export var tex_edge: Texture2D   # Flat edge on TOP (we will rotate it)
@export var tex_corner: Texture2D # Outer corner on TOP-LEFT (we will rotate it)


@onready var sprite_node = $Sprite 

func _ready():
	super._ready()
 
# Called by LevelGenerator
func update_appearance(n: Dictionary):
	if not sprite_node: return
	
	# n = { "N": bool, "S": bool, "E": bool, "W": bool }
	# True means "There is Water here". False means "Land/Empty".
	
	var is_north = n["N"]
	var is_south = n["S"]
	var is_east =  n["E"]
	var is_west =  n["W"]

	# --- LOGIC TREE ---
	
	# 1. CENTER (Surrounded by water)
	if is_north and is_south and is_east and is_west:
		set_visual(tex_center, 0)
		return

	# 2. CORNERS (Two adjacent sides are empty)
	# Check Top-Left Corner (No Water North, No Water West)
	if not is_north and not is_west:
		set_visual(tex_corner, 0) # 0 degrees
		return
	# Top-Right (No Water North, No Water East)
	if not is_north and not is_east:
		set_visual(tex_corner, 90)
		return
	# Bottom-Right (No Water South, No Water East)
	if not is_south and not is_east:
		set_visual(tex_corner, 180)
		return
	# Bottom-Left (No Water South, No Water West)
	if not is_south and not is_west:
		set_visual(tex_corner, 270)
		return

	# 3. EDGES (One side is empty)
	# Top Edge (No Water North)
	if not is_north:
		set_visual(tex_edge, 90)
		return
	# Right Edge (No Water East)
	if not is_east:
		set_visual(tex_edge, 0)
		return
	# Bottom Edge (No Water South)
	if not is_south:
		set_visual(tex_edge, 270)
		return
	# Left Edge (No Water West)
	if not is_west:
		set_visual(tex_edge, 180)
		return

	# Fallback (e.g., single puddle or weird shape)
	set_visual(tex_center, 0)

func set_visual(texture: Texture2D, degrees: float):
	if texture:
		sprite_node.texture = texture
	self.rotation_degrees = degrees
