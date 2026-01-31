@tool
extends GameObject
class_name Mask

# Match Player's MaskType enum
enum MaskType { NONE, DIMENSION, WATER }

@export var mask_type: MaskType = MaskType.DIMENSION
var sprite: ColorRect
var label: Label

func _ready():
	# Masks are not solid, player can walk through them

	# Create sprite if it doesn't exist
	if not sprite:
		create_sprite()

	# Call parent ready to register with grid
	super._ready()

func create_sprite():
	# Remove any existing children first
	for child in get_children():
		if child is ColorRect or child is Label:
			child.queue_free()

	# Create visual representation
	sprite = ColorRect.new()
	sprite.size = Vector2(48, 48)
	sprite.position = Vector2(-24, -24)
	sprite.color = get_mask_color()
	add_child(sprite)

	# Add label
	label = Label.new()
	label.position = Vector2(-28, 16)
	label.size = Vector2(56, 20)
	label.text = get_mask_name()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	add_child(label)

func get_mask_color() -> Color:
	match mask_type:
		MaskType.DIMENSION:
			return Color(0.8, 0.2, 0.8, 1)  # Purple
		MaskType.WATER:
			return Color(0.2, 0.6, 0.9, 1)  # Blue
		_:
			return Color(1, 1, 1, 1)

func get_mask_name() -> String:
	match mask_type:
		MaskType.DIMENSION:
			return "DIM"
		MaskType.WATER:
			return "WATER"
		_:
			return "MASK"

func pickup():
	# Called when player picks up this mask
	queue_free()
