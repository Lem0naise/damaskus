extends Node2D

class_name EntityTooltip

@onready var panel: PanelContainer = $PanelContainer
@onready var label: Label = $PanelContainer/MarginContainer/Label

# Load Font (can be shared or preloaded)
var font = preload("res://assets/PixelifySans-Regular.ttf")

func _ready():
	# Ensure Z-Index is high so it draws over map elements
	z_index = 100
	
	# Create UI if not present (Scene vs Script usage)
	if not has_node("PanelContainer"):
		create_visuals()
	else:
		panel = $PanelContainer
		label = $PanelContainer/MarginContainer/Label
	
	# Hide by default
	hide_tooltip()

func create_visuals():
	panel = PanelContainer.new()
	panel.name = "PanelContainer"
	add_child(panel)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.85) # Transparent dark blue-ish
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	style.content_margin_left = 8
	style.content_margin_right = 8
	panel.add_theme_stylebox_override("panel", style)
	
	# Make it grow from center bottom
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	
	var margin = MarginContainer.new()
	margin.name = "MarginContainer"
	panel.add_child(margin)
	
	label = Label.new()
	label.name = "Label"
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 20) # Smaller font
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	margin.add_child(label)
	
	# Center the panel horizontally relative to (0,0)
	# PanelContainer is a Control, so we set its position to center it
	# But since size is dynamic, we might need to update position on text change
	# Or use Grow Direction
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	# Position slightly above (default, will be updated in show_tooltip)
	panel.position.y = -100

func show_tooltip(text: String):
	# print("EntityTooltip: Showing '", text, "'")
	if label:
		label.text = text
	
	visible = true
	
	if panel:
		panel.visible = true
		# Force layout update
		panel.reset_size()
		
		# Center horizontally, place above head
		# Assuming origin is center of entity
		panel.position.x = - panel.size.x / 2
		panel.position.y = - panel.size.y - 95 # 95px above center (clears 180px sprite half-height of 90)

func hide_tooltip():
	visible = false
