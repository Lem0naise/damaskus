extends GameObject
class_name Mask

# Match Player's MaskType enum
enum MaskType { NONE, DIMENSION, WATER, WINNER, BATTERING_RAM, GOLEM }

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
	
	# --- COLOR SHIFT LOGIC ---
	# We use 'modulate' to tint the texture.
	# Check if the node exists first to prevent crashes.
	if has_node("TextureRect"):
		$TextureRect.modulate = get_mask_color()
	else:
		print("Warning: No TextureRect found on Mask object")

func get_mask_color() -> Color:
	match mask_type:
		MaskType.DIMENSION: return Color(0.8, 0.2, 0.8, 1) # Purple
		MaskType.WATER:     return Color(0.2, 0.6, 0.9, 1) # Blue
		MaskType.WINNER:    return Color(0.827, 0.667, 0.326, 1.0)  # Blue for WATER
		MaskType.BATTERING_RAM: return Color(0.8, 0.3, 0.2, 1) # Red/Orange
		MaskType.GOLEM:     return Color(0.5, 0.4, 0.3, 1) # Brown/Gray
		_:                  return Color(1, 1, 1, 0.5)

func get_mask_name() -> String:
	match mask_type:
		MaskType.DIMENSION: return "DIM"
		MaskType.WATER:     return "H2O"
		MaskType.WINNER:   	return "GOAL"
		MaskType.BATTERING_RAM: return "RAM"
		MaskType.GOLEM:     return "ROCK"
		_:                  return "?"

func get_mask_description() -> String:
	match mask_type:
		MaskType.DIMENSION: return "Shift dimensions (Space)"
		MaskType.WATER:     return "Walk on water"
		MaskType.BATTERING_RAM: return "Smash through crumbled walls"
		MaskType.GOLEM:     return "Push rocks to create bridges"
		MaskType.WINNER:    return "Equip to win!"
		_:                  return ""

func pickup():
	# Player calls this when collecting
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
