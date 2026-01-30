extends Node2D

@onready var grid_manager: GridManager = $GridManager

func _ready():
	# Game objects now register themselves automatically
	# No need to manually register walls and water
	print("Ingame scene ready")
