@tool
extends GameObject
class_name Wall

var sprite: ColorRect

func _ready():
	# Set wall properties
	is_solid = true
	is_pushable = false
	object_type = "wall"

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
	sprite.color = Color(0.5, 0.3, 0.2, 1)  # Brown
	add_child(sprite)
