extends BaseButton

## The Input Map action name this button should trigger (e.g., "ui_left", "jump")
@export var action_name: String = ""

func _ready() -> void:
	# BaseButton emits button_down and button_up signals
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_button_down() -> void:
	if action_name != "":
		Input.action_press(action_name)

func _on_button_up() -> void:
	if action_name != "":
		Input.action_release(action_name)

func _exit_tree() -> void:
	# Safety cleanup to ensure action doesn't get stuck if button is removed while held
	if is_pressed() and action_name != "":
		Input.action_release(action_name)
