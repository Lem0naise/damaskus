extends GameObject
class_name Mask

# Match Player's MaskType enum
enum MaskType { NONE, DIMENSION, WATER }

# The Generator will set this variable before adding the child
@export var mask_type: MaskType = MaskType.NONE

func _ready():
	# 1. Setup Visuals based on the type assigned by the LevelGenerator
	setup_visuals()
	
	super._ready()

func setup_visuals():


	var label = Label.new()
	label.position = Vector2(-28, -10)
	label.size = Vector2(56, 20)
	label.text = get_mask_name()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	add_child(label)

func get_mask_color() -> Color:
	match mask_type:
		MaskType.DIMENSION: return Color(0.8, 0.2, 0.8, 1) # Purple
		MaskType.WATER:     return Color(0.2, 0.6, 0.9, 1) # Blue
		_:                  return Color(1, 1, 1, 0.5)

func get_mask_name() -> String:
	match mask_type:
		MaskType.DIMENSION: return "DIM"
		MaskType.WATER:     return "H2O"
		_:                  return "?"

func pickup():
	# Player calls this when collecting
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
