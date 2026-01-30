extends GameObject
class_name Wall

func _ready():
	# Set wall properties
	is_solid = true
	is_pushable = false
	object_type = "wall"

	# Call parent ready to register with grid
	super._ready()
