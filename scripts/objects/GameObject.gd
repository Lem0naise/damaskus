extends Node2D
class_name GameObject

# We still reference the GridManager for interactions, but NOT for registration
@onready var grid_manager: GridManager = get_node_or_null("/root/Ingame/GridManager")

func _ready():
	# Objects are always visible - no dimension system
	pass

# --- Interactions ---
# Keep these so the Player script can still call them!

func on_player_interact():
	pass

func on_pushed(direction: Vector2i) -> bool:
	return false
