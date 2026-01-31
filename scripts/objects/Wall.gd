extends GameObject
class_name Wall

# No @tool needed anymore! 

func _ready():
	# 1. Define properties for Gameplay interactions
	# (The GridManager knows this is a wall, but the Player might check these)
	#is_solid = true
	#is_pushable = false
	#object_type = "wall"

	# 2. Visual Setup
	# ideally, you set the texture in the Editor, not code.
	# But if you want to keep your placeholder box for now:

	# 3. Initialize GameObject logic (Dimension visibility)
	super._ready()
