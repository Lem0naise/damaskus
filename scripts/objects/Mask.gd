extends GameObject
class_name Mask

# Match Player's MaskType enum
enum MaskType {NONE, DIMENSION, WATER, WINNER, BATTERING_RAM, GOLEM}

# The Generator will set this variable before adding the child
@export var mask_type: MaskType = MaskType.NONE


@export var water_mask_still: Texture2D
@export var water_mask_walking: Texture2D

@export var win_mask_still: Texture2D
@export var win_mask_walking: Texture2D


func _ready():
	# 1. Setup Visuals based on the type assigned by the LevelGenerator
	setup_visuals()
	
	super._ready()

func setup_visuals():
	var label = Label.new()
	label.position = Vector2(-28, -10)
	label.size = Vector2(56, 20)
	label.text =""
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	add_child(label)
	
	# --- COLOR SHIFT LOGIC ---
	# We use 'modulate' to tint the texture.
	# Check if the node exists first to prevent crashes.
	if has_node("TextureRect"):
		if mask_type == MaskType.WINNER:
			$TextureRect.hide()
			$CrownRect.show()
			$CrownRect.texture = get_mask_texture()
		else :
			$TextureRect.show()
			$CrownRect.hide()
			$TextureRect.texture = get_mask_texture()
	else:
		print("Warning: No TextureRect found on Mask object")

func get_mask_texture() -> Texture2D:
	match mask_type:
		MaskType.DIMENSION: return null # Purple
		MaskType.WATER:     return water_mask_still
		MaskType.WINNER:    return win_mask_still
		MaskType.BATTERING_RAM: return win_mask_still
		MaskType.GOLEM: return win_mask_still
		_:                  return null

func get_mask_name() -> String:
	match mask_type:
		MaskType.DIMENSION: return "DIM"
		MaskType.WATER: return "H2O"
		MaskType.WINNER: return "GOAL"
		MaskType.BATTERING_RAM: return "RAM"
		MaskType.GOLEM: return "GOLEM"
		_: return "?"

func get_mask_description() -> String:
	match mask_type:
		MaskType.DIMENSION: return "Shift dimensions (Space)"
		MaskType.WATER: return "Walk on water"
		MaskType.BATTERING_RAM: return "Smash through crumbled walls"
		MaskType.GOLEM: return "Push rocks!"
		MaskType.WINNER: return "Equip to win!"
		_: return ""

func pickup():
	# Player calls this when collecting
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
