extends Node2D

@onready var grid_manager: GridManager = $GridManager

func _ready():
	# Game objects now register themselves automatically
	# No need to manually register walls and water
	$Background.modulate.a = 0
	
	# Ensure death screen is hidden at start
	if has_node("Death"):
		$Death.modulate.a = 0
		$Death.visible = true # It's visible but fully transparent
		
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	
	tween.tween_property($Background, "modulate:a", 1, 0.3)
	
	print("Ingame scene ready")

func trigger_death(reason: String):
	print("DEATH TRIGGERED: ", reason)
	
	# 1. Show Message
	var msg_label = $Death/Message
	if msg_label:
		msg_label.text = reason
		
	# 2. Fade In Black Screen
	var death_rect = $Death
	if death_rect:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(death_rect, "modulate:a", 1.0, 0.5)
		
		# 3. Wait and Reload
		tween.tween_interval(2.0)
		tween.tween_callback(reload_level)

func next_level():
	$LevelGenerator.next_level()

func reload_level():
	# Reset death screen for next time (though scene reload might handle this, safer to return values)
	if has_node("Death"):
		$Death.modulate.a = 0
		
	$Player.remove_mask()
	$NPC.remove_mask()
	$LevelGenerator.reload_level()
