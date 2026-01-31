extends CanvasLayer

@onready var inventory_container: VBoxContainer = $InventoryContainer
@onready var player: Player = get_node("/root/Ingame/Player")

func _ready():
	# Position in top-right
	inventory_container.position = Vector2(1720, 20)

func update_inventory(inventory: Array, equipped_mask):
	# Clear existing items
	for child in inventory_container.get_children():
		if child is HBoxContainer:
			child.queue_free()

	# Add title
	if inventory_container.get_child_count() == 0:
		var title = Label.new()
		title.text = "INVENTORY"
		title.add_theme_font_size_override("font_size", 14)
		inventory_container.add_child(title)

	# Add each mask in inventory
	for mask_type in inventory:
		var row = HBoxContainer.new()

		# Equipped indicator
		var indicator = Label.new()
		indicator.text = ">" if mask_type == equipped_mask else " "
		indicator.add_theme_font_size_override("font_size", 12)
		row.add_child(indicator)

		# Mask name
		var mask_label = Label.new()
		mask_label.text = get_mask_name(mask_type)
		mask_label.add_theme_font_size_override("font_size", 12)
		row.add_child(mask_label)

		inventory_container.add_child(row)

	# Add controls hint
	if inventory.size() > 0:
		var hint = Label.new()
		hint.text = "\n[R] Equip  [Space] Use"
		hint.add_theme_font_size_override("font_size", 10)
		inventory_container.add_child(hint)

func get_mask_name(mask_type) -> String:
	match mask_type:
		0: return "NONE"
		1: return "DIMENSION"
		2: return "WATER"
		_: return "UNKNOWN"
