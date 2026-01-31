extends Node2D

@onready var grid_manager: GridManager = $GridManager

func _ready():
	# Game objects now register themselves automatically
	# No need to manually register walls and water
	
	$Background.modulate.a = 0
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	
	tween.tween_property($Background, "modulate:a", 1, 0.3)
	
	print("Ingame scene ready")
