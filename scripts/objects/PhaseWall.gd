extends Node2D

@onready var sprite = $TextureRect
@onready var grid_manager = get_node("/root/Ingame/GridManager")

# --- SETTINGS ---
@export var is_red_wall: bool = true # Check this for Red Wall, uncheck for Blue
@export var texture_up: Texture2D    # The "Blocking" Pillar image
@export var texture_down: Texture2D  # The "Passable" Flat/Hole image

func _process(delta):
	update_visual_state()

func update_visual_state():
	# 1. Check if anyone has the power to phase
	var player = get_node_or_null("/root/Ingame/Player")
	var npc = get_node_or_null("/root/Ingame/NPC")
	
	var player_has = player and player.has_property("DIMENSION_SHIFT")
	var npc_has = npc and npc.is_active and npc.has_property("DIMENSION_SHIFT")
	var power_active = player_has or npc_has

	# 2. Default: Pillar is UP (Blocking)
	var is_down = false

	# 3. If power is active, check if we match the current phase mode
	if power_active:
		if is_red_wall and grid_manager.is_red_mode:
			is_down = true # Red mode active -> Red walls go down
		elif not is_red_wall and not grid_manager.is_red_mode:
			is_down = true # Blue mode active -> Blue walls go down

	# 4. Apply Texture
	if is_down:
		sprite.texture = texture_down
		# Optional: Make it semi-transparent or darker to look "inactive"
		modulate = Color(1, 1, 1, 0.5) 
	else:
		sprite.texture = texture_up
		modulate = Color(1, 1, 1, 1.0)
