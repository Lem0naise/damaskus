@tool
extends GameObject
class_name Water

func _ready():
	# Set water properties
	is_solid = true  # Blocks movement by default (unless player has FLOAT)
	is_pushable = false
	object_type = "water"

	# Call parent ready to register with grid
	super._ready()

# In the future, you can override this to check for FLOAT property
# For now, water just blocks movement like a wall
