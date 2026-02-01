extends CanvasLayer

@onready var inventory_container: PanelContainer = $InventoryPanel
@onready var masks_container: VBoxContainer = $InventoryPanel/MarginContainer/VBoxContainer

# Load Font
var font = preload("res://assets/PixelifySans-Regular.ttf")

func _ready():
	setup_ui()
	hide_pickup_tooltip()

func setup_ui():
	# --- Main Inventory Panel ---
	# Create if not exists (handling scene vs script only setup)
	if not has_node("InventoryPanel"):
		var panel = PanelContainer.new()
		panel.name = "InventoryPanel"
		add_child(panel)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_bottom_left = 8
		style.content_margin_top = 10
		style.content_margin_bottom = 10
		style.content_margin_left = 10
		style.content_margin_right = 10
		panel.add_theme_stylebox_override("panel", style)
		
		var margin = MarginContainer.new()
		margin.name = "MarginContainer"
		panel.add_child(margin)
		
		var vbox = VBoxContainer.new()
		vbox.name = "VBoxContainer"
		margin.add_child(vbox)

	# Re-assign onready vars for safety
	inventory_container = $InventoryPanel
	masks_container = $InventoryPanel/MarginContainer/VBoxContainer

	# Position: Top Right with some padding
	inventory_container.anchor_right = 1.0
	inventory_container.anchor_top = 0.0
	inventory_container.anchor_left = 1.0
	inventory_container.anchor_bottom = 0.0
	inventory_container.position = Vector2(1920 - 250, 20) # Approx
	inventory_container.size = Vector2(230, 0) # Min fixed width
	
	# Hide by default until updated
	inventory_container.visible = false

func update_inventory(inventory: Array, equipped_mask):
	# Ensure UI is set up if called early
	if not masks_container:
		setup_ui()

	# Clear existing items
	for child in masks_container.get_children():
		child.queue_free()

	# Title
	var title = Label.new()
	title.text = "INVENTORY"
	title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	masks_container.add_child(title)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 5)
	masks_container.add_child(spacer)

	if inventory.size() == 0:
		inventory_container.visible = false
		return
	else:
		inventory_container.visible = true
	
	for mask_type in inventory:
		var row_container = PanelContainer.new()
		var row_style = StyleBoxFlat.new()
		row_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
		row_style.corner_radius_top_left = 4
		row_style.corner_radius_top_right = 4
		row_style.corner_radius_bottom_right = 4
		row_style.corner_radius_bottom_left = 4
		
		# Highlight if equipped
		if mask_type == equipped_mask:
			row_style.border_width_left = 4
			row_style.border_color = Color(1, 0.8, 0.2, 1) # Gold border
			row_style.bg_color = Color(0.3, 0.3, 0.3, 0.8)
		
		row_container.add_theme_stylebox_override("panel", row_style)
		
		var row_margin = MarginContainer.new()
		row_margin.add_theme_constant_override("margin_left", 8)
		row_margin.add_theme_constant_override("margin_right", 8)
		row_margin.add_theme_constant_override("margin_top", 4)
		row_margin.add_theme_constant_override("margin_bottom", 4)
		row_container.add_child(row_margin)
		
		var row_hbox = HBoxContainer.new()
		row_margin.add_child(row_hbox)
		
		# Color Block Icon
		var color_rect = ColorRect.new()
		color_rect.custom_minimum_size = Vector2(16, 16)
		color_rect.color = get_mask_color(mask_type)
		color_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row_hbox.add_child(color_rect)
		
		# Name
		var name_label = Label.new()
		# Use index + 1 for display number
		var display_idx = inventory.find(mask_type) + 1
		name_label.text = "[%d] %s" % [display_idx, get_mask_display_name(mask_type)]
		name_label.add_theme_font_override("font", font)
		name_label.add_theme_font_size_override("font_size", 18)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_hbox.add_child(name_label)
		
		masks_container.add_child(row_container)

	# Controls Hint Footer
	var footer_spacer = Control.new()
	footer_spacer.custom_minimum_size = Vector2(0, 10)
	masks_container.add_child(footer_spacer)
	
	var footer = Label.new()
	footer.text = "[1-9] Select Mask"
	if equipped_mask != 0:
		var mask_name = get_mask_name_internal(equipped_mask)
		if mask_name == "DIMENSION":
			footer.text += "\n[Space] Shift"
	footer.add_theme_font_override("font", font)
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	masks_container.add_child(footer)

func hide_pickup_tooltip():
	pass

# --- Helpers ---
func get_mask_name_internal(mask_type) -> String:
	match mask_type:
		0: return "NONE"
		1: return "DIMENSION"
		2: return "WATER"
		3: return "WINNER"
		4: return "BATTERING_RAM"
		5: return "DAMASCUS"
		_: return "UNKNOWN"

func get_mask_display_name(mask_type) -> String:
	match mask_type:
		1: return "Dimension"
		2: return "Water"
		3: return "Equip to Win!"
		4: return "Battering Ram"
		5: return "Damascus Steel"
		_: return "Unknown"

func get_mask_color(mask_type) -> Color:
	match mask_type:
		1: return Color(0.8, 0.2, 0.8, 1) # Purple for DIMENSION
		2: return Color(0.2, 0.6, 0.9, 1) # Blue for WATER
		3: return Color(0.827, 0.667, 0.326, 1.0) # Gold for WINNER
		4: return Color(0.8, 0.3, 0.2, 1) # Red/Orange for RAM
		5: return Color(0.7, 0.7, 0.75, 1.0) # Steel/Silver for DAMASCUS
		_: return Color(1, 1, 1, 1)
