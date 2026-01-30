@tool
extends GameObject
class_name Water

var sprite: ColorRect

func _ready():
	# Set water properties
	is_solid = true  # Blocks movement by default (unless player has FLOAT)
	is_pushable = false
	object_type = "water"

	# Create sprite if it doesn't exist
	if not sprite:
		create_sprite()

	# Call parent ready to register with grid
	super._ready()

func create_sprite():
	# Remove any existing child sprites/labels first
	for child in get_children():
		if child is ColorRect or child is Label:
			child.queue_free()

	sprite = ColorRect.new()
	sprite.size = Vector2(64, 64)
	sprite.position = Vector2(-32, -32)
	sprite.color = Color(0.2, 0.4, 0.8, 1)  # Blue
	add_child(sprite)

# In the future, you can override this to check for FLOAT property
# For now, water just blocks movement like a wall
