extends CharacterBody2D
class_name PlayerMainMenu

# --- References ---
@onready var grid_manager: GridManager = get_node("/root/MainMenu/GridManager")
@onready var sprite: Sprite2D = $Sprite

# UI Button References
@onready var btn_start: Button = get_node("/root/MainMenu/UI_Layer/MenuBox/Btn_Start")
@onready var btn_options: Button = get_node("/root/MainMenu/UI_Layer/MenuBox/Btn_Options")
@onready var btn_quit: Button = get_node("/root/MainMenu/UI_Layer/MenuBox/Btn_Quit")

# --- Configuration ---
# Format: { Vector2i(x,y): "action_name" }
var button_map: Dictionary = {}

func _ready():
	# 1. Setup Grid
	if grid_manager:
		grid_position = grid_manager.world_to_grid(global_position)
		global_position = grid_manager.grid_to_world(grid_position)
	set_sprite_texture(texture_still)
	
	# 2. DEFINE BUTTON AREAS HERE
	# register_button_area(action_name, start_x, start_y, width, height)
	
	# Example: Start button starts at (6,5), is 3 tiles wide, and 2 tiles high
	register_button_area("start",   6, 5, 3, 2) 
	
	# Example: Options button starts at (1,6), is 3 tiles wide, 1 tile high
	register_button_area("options", 1, 6, 3, 2) 
	
	# Example: Quit button starts at (6,10), is 3 tiles wide, 1 tile high
	register_button_area("quit",    12, 7, 2, 2) 

# --- Helper to register a RECTANGLE of tiles ---
func register_button_area(action: String, start_x: int, start_y: int, width: int, height: int):
	for x in range(width):
		for y in range(height):
			var pos = Vector2i(start_x + x, start_y + y)
			button_map[pos] = action
			
	print("Registered '", action, "' area starting at (", start_x, ",", start_y, ") size: ", width, "x", height)

# --- Standard Variables ---
var texture_still: Texture2D = preload("res://assets/SpriteStillTransparent.png")
var texture_walking: Texture2D = preload("res://assets/SpriteMovingTransparent.png")
const SPRITE_SIZE = 360.0 
var grid_position: Vector2i = Vector2i.ZERO
var is_moving: bool = false
var move_duration: float = 0.18
var next_move: Vector2i = Vector2i.ZERO
var move_cooldown: float = 0.0
const HELD_KEY_DELAY = 0.12
const HELD_KEY_INITIAL_DELAY = 0.25
var held_key_timer: float = 0.0
var last_held_direction: Vector2i = Vector2i.ZERO
var is_intangible: bool = true 

func _process(delta):
	if move_cooldown > 0: move_cooldown -= delta
	if held_key_timer > 0: held_key_timer -= delta
	handle_input()
	
	if not is_moving and next_move != Vector2i.ZERO and move_cooldown <= 0:
		var buffered_move = next_move
		next_move = Vector2i.ZERO
		try_move(buffered_move)

func handle_input():
	# 1. CHECK FOR E PRESSED
	if Input.is_action_just_pressed("pickup"): 
		interact_with_menu()
		return 

	# 2. Movement Input
	var input_dir = Vector2i.ZERO
	var is_just_pressed = false

	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_d"):
		input_dir = Vector2i.RIGHT; is_just_pressed = true; held_key_timer = HELD_KEY_INITIAL_DELAY
	elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_a"):
		input_dir = Vector2i.LEFT; is_just_pressed = true; held_key_timer = HELD_KEY_INITIAL_DELAY
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_s"):
		input_dir = Vector2i.DOWN; is_just_pressed = true; held_key_timer = HELD_KEY_INITIAL_DELAY
	elif Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_w"):
		input_dir = Vector2i.UP; is_just_pressed = true; held_key_timer = HELD_KEY_INITIAL_DELAY

	if not is_just_pressed and not is_moving and move_cooldown <= 0 and held_key_timer <= 0:
		if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_d"): input_dir = Vector2i.RIGHT
		elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_a"): input_dir = Vector2i.LEFT
		elif Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_s"): input_dir = Vector2i.DOWN
		elif Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_w"): input_dir = Vector2i.UP
		else: held_key_timer = 0

	if input_dir != Vector2i.ZERO:
		if is_moving: next_move = input_dir
		elif move_cooldown <= 0: try_move(input_dir)

func interact_with_menu():
	print("Player interaction at: ", grid_position)
	
	# Check our lookup map for the current position
	if button_map.has(grid_position):
		var action = button_map[grid_position]
		print("Triggers Action: ", action)
		
		match action:
			"start":
				btn_start.pressed.emit()
			"options":
				btn_options.pressed.emit()
			"quit":
				btn_quit.pressed.emit()
	else:
		print("No button at this location.")

func try_move(direction: Vector2i):
	var target_grid_pos = grid_position + direction
	if can_move_to(target_grid_pos):
		grid_position = target_grid_pos
		is_moving = true
		set_sprite_texture(texture_walking)
		if direction == Vector2i.LEFT: sprite.flip_h = true
		elif direction == Vector2i.RIGHT: sprite.flip_h = false
		move_cooldown = HELD_KEY_DELAY

		# Tween Movement
		var target_world_pos = grid_manager.grid_to_world(grid_position)
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "global_position", target_world_pos, move_duration)
		tween.tween_callback(on_movement_finished)

func on_movement_finished():
	is_moving = false
	set_sprite_texture(texture_still)
	if next_move != Vector2i.ZERO:
		var buffered_move = next_move
		next_move = Vector2i.ZERO
		try_move(buffered_move)

func can_move_to(target_pos: Vector2i) -> bool:
	if not grid_manager: return false
	if not grid_manager.is_valid_position(target_pos): return false
	return true 

func set_sprite_texture(texture: Texture2D):
	if not sprite: sprite = $Sprite
	if not sprite: return
	sprite.texture = texture
	if texture:
		var texture_size = texture.get_size()
		var scale_factor = SPRITE_SIZE / max(texture_size.x, texture_size.y)
		sprite.scale = Vector2(scale_factor, scale_factor)
