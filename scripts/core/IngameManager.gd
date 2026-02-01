extends Node2D

@onready var grid_manager: GridManager = $GridManager

func _ready():
	# Game objects now register themselves automatically
	# No need to manually register walls and water
	$Background.modulate.a = 0
	
	# Ensure death screen is hidden at start
	if has_node("DeathLayer"):
		$DeathLayer.visible = true
		$DeathLayer/Death.modulate.a = 0
		$DeathLayer/Message.modulate.a = 0 # Hide message initially via modulate
		$DeathLayer/Message.visible = true
		
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	
	tween.tween_property($Background, "modulate:a", 1, 0.3)
	
	print("Ingame scene ready")

func trigger_death(reason: String):
	print("DEATH TRIGGERED: ", reason)
	
	$InventoryUI.hide_pickup_tooltip()
	
	var death_rect = $DeathLayer/Death
	var msg_label = $DeathLayer/Message
	
	if death_rect and msg_label:
		msg_label.text = reason
		
		# RED FLASH ANIMATION
		# The Death Rect is a ColorRect with color=Color(0.4, 0, 0, 1) currently (from tscn)
		# We want it to "Flash red, then go to red"
		
		# 1. Reset Modulate to clear
		death_rect.modulate = Color(1, 1, 1, 0)
		
		# 2. Set the ColorRect's intrinsic color to bright red for the flash?
		# Or just modulate it?
		# Let's override the ColorRect color to be PURE RED for the flash
		death_rect.color = Color(1, 0, 0, 1)
		
		var tween = create_tween()
		
		# 3. Flash In: Alpha 0 -> 1 (Show Pure Red) very fast
		tween.tween_property(death_rect, "modulate:a", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(death_rect, "modulate:r", 0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		# 4. "Then going to red" (maybe a darker red? or stay pure red?)
		
		# 5. Message Fade In
		tween.parallel().tween_property(msg_label, "modulate:a", 1.0, 0.1).set_delay(0.1)
		
		# 3. Wait and Reload
		tween.tween_interval(1)
		tween.tween_callback(reload_level)

func next_level():
	$LevelGenerator.next_level()

func reload_level():
	# Reset death screen for next time (though scene reload might handle this, safer to return values)
	if has_node("DeathLayer"):
		$DeathLayer/Death.modulate.a = 0
		$DeathLayer/Message.modulate.a = 0
		
	$Player.remove_mask()
	$NPC.remove_mask()
	$LevelGenerator.reload_level()
