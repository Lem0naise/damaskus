extends CanvasLayer

func _ready() -> void:
	# Initial check
	_update_visibility()
	
	# Connect to changes
	if GameSettings:
		GameSettings.mobile_controls_changed.connect(_on_mobile_controls_changed)
	else:
		push_error("GameSettings singleton not found! Make sure it is autoloaded.")

func _on_mobile_controls_changed(_enabled: bool) -> void:
	_update_visibility()

func _update_visibility() -> void:
	# Hide/Show the root control or the layer itself
	self.visible = GameSettings.mobile_controls_enabled
	print(self.visible)
	print("mobile controls: i am visible or not, see above")
