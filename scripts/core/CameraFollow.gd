extends Camera2D

@export var target_path: NodePath
var target: Node2D

func _ready():
	if target_path:
		target = get_node(target_path)

func _process(_delta):
	if target:
		global_position = target.global_position
