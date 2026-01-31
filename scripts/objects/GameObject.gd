extends Node2D
class_name GameObject

# We still reference the GridManager for interactions, but NOT for registration
@onready var grid_manager: GridManager = get_node_or_null("/root/Ingame/GridManager")

# Identify what dimension this object is visible in
@export var dimension_ids: Array = [0] 

# Visual Only logic
func _ready():
	# Ensure visibility is correct on spawn
	var current_dim = 0 # Default or fetch from a global manager
	update_dimension_visibility(current_dim)

func update_dimension_visibility(active_dimension: int):
	visible = active_dimension in dimension_ids
	# If using physics bodies for other things, disable them too
	if has_node("CollisionShape2D"):
		get_node("CollisionShape2D").disabled = not (active_dimension in dimension_ids)

# --- Interactions ---
# Keep these so the Player script can still call them!

func on_player_interact():
	pass

func on_pushed(direction: Vector2i) -> bool:
	return false
