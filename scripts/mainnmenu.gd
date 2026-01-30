extends Control

# -- Configuration --
# Path to your main game scene
const GAME_SCENE_PATH: String = "res://game/levels/level_01.tscn"

# -- Nodes (Using Unique Names % for stability in 4.6) --
@onready var start_btn: Button = %Btn_Start
@onready var options_btn: Button = %Btn_Options
@onready var quit_btn: Button = %Btn_Quit
@onready var mask_overlay: TextureRect = $MaskOverlay
@onready var fade_layer: ColorRect = $FadeLayer

func _ready() -> void:
	# 1. Connect signals
	start_btn.pressed.connect(_on_start_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	# 2. Intro Animation: Fade from black, float the mask
	_play_intro_anim()

func _play_intro_anim() -> void:
	# Ensure fade layer starts black and fades out
	fade_layer.color = Color.BLACK
	fade_layer.show()
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade_layer, "modulate:a", 0.0, 1.5)
	
	# Subtle "breathing" animation for the mask
	var mask_tween = create_tween().set_loops()
	mask_tween.tween_property(mask_overlay, "scale", Vector2(1.05, 1.05), 2.0).set_trans(Tween.TRANS_SINE)
	mask_tween.tween_property(mask_overlay, "scale", Vector2(1.0, 1.0), 2.0).set_trans(Tween.TRANS_SINE)

func _on_start_pressed() -> void:
	# Lock input to prevent double-clicks
	set_process_input(false)
	
	# THEME: The "Unmasking" Transition
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	
	# 1. Scale the mask up hugely until it "consumes" the screen (entering the mask)
	# Assumes pivot offset is set to center of the texture
	mask_overlay.pivot_offset = mask_overlay.size / 2
	tween.tween_property(mask_overlay, "scale", Vector2(30, 30), 1.2)
	tween.tween_property(mask_overlay, "modulate:a", 0.0, 1.0).set_delay(0.5)
	
	# 2. Fade UI out quickly
	tween.tween_property(%MenuBox, "modulate:a", 0.0, 0.3)
	
	# 3. Wait for tween to finish, then change scene
	await tween.finished
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_options_pressed() -> void:
	# Placeholder for options menu logic
	print("Options menu requested")
	# You might instantiate a settings scene or show a hidden panel here

func _on_quit_pressed() -> void:
	# Standard quit with a quick fade for polish
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	get_tree().quit()
