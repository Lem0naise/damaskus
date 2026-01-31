extends CanvasLayer

@onready var inventory_container: VBoxContainer = $InventoryContainer
@onready var player: Player = get_node("/root/Ingame/Player")

func _ready():
	# Position in top-right
	inventory_container.position = Vector2(1720, 20)

func update_inventory(inventory: Array, equipped_mask):
	# Clear ALL existing children
	for child in inventory_container.get_children():
		child.queue_free()

	# Add title
	var title = Label.new()
	title.text = "=== MASKS ==="
	title.add_theme_font_size_override("font_size", 14)
	inventory_container.add_child(title)

	# Show empty state
	if inventory.size() == 0:
		var empty = Label.new()
		empty.text = "\n(None collected)"
		empty.add_theme_font_size_override("font_size", 11)
		inventory_container.add_child(empty)
		return

	# Add spacer
	var spacer = Label.new()
	spacer.text = " "
	inventory_container.add_child(spacer)

	# Add each mask in inventory
	for mask_type in inventory:
		var row = HBoxContainer.new()

		# Equipped indicator
		var indicator = Label.new()
		indicator.text = " > " if mask_type == equipped_mask else "   "
		indicator.add_theme_font_size_override("font_size", 12)
		row.add_child(indicator)

		# Mask name with color
		var mask_label = Label.new()
		mask_label.text = get_mask_display_name(mask_type)
		mask_label.add_theme_font_size_override("font_size", 12)
		mask_label.add_theme_color_override("font_color", get_mask_color(mask_type))
		row.add_child(mask_label)

		inventory_container.add_child(row)

	# Add controls hint
	var hint = Label.new()
	hint.text = "\n[E] Pickup"
	hint.text += "\n[R] Cycle Masks"
	if equipped_mask != 0:  # If something is equipped
		var mask_name = get_mask_name(equipped_mask)
		print(equipped_mask)
		if mask_name == "DIMENSION":
			hint.text += "\n[Space] Shift Dim"
		elif mask_name == "WATER":
			hint.text += "\n(Walk on water)"
		if mask_name == "WINNER":
			hint.text += "\n You should already have won!"
	hint.add_theme_font_size_override("font_size", 10)
	hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	inventory_container.add_child(hint)

func get_mask_name(mask_type) -> String:
	match mask_type:
		0: return "NONE"
		1: return "DIMENSION"
		2: return "WATER"
		3: return "WINNER"
		_: return "UNKNOWN"

func get_mask_display_name(mask_type) -> String:
	match mask_type:
		1: return "Dimension"
		2: return "Water"
		3: return "Equip to Win!"
		_: return "Unknown"

func get_mask_color(mask_type) -> Color:
	match mask_type:
		1: return Color(0.8, 0.2, 0.8, 1)  # Purple for DIMENSION
		2: return Color(0.2, 0.6, 0.9, 1)  # Blue for WATER
		3: return Color(0.827, 0.667, 0.326, 1.0)  # Gold for WINNER
		_: return Color(1, 1, 1, 1)
