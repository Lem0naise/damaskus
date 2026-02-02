extends Control

@onready var level_list: VBoxContainer = $ScrollContainer/LevelList
@onready var loading_spinner: Label = $LoadingSpinner
@onready var sort_dropdown: OptionButton = $SortDropdown
@onready var back_button: Button = $BackButton
@onready var submit_label: Label = $SubmitLabel

var level_card_scene = preload("res://scenes/ui/level_card.tscn")
var all_levels: Array = [] # Store all levels for client-side sorting

func _ready():
	$Black.hide()
	CommunityAPI.levels_fetched.connect(_on_levels_fetched)
	CommunityAPI.level_loaded.connect(_on_level_loaded)
	CommunityAPI.error_occurred.connect(_on_error)

	back_button.pressed.connect(_on_back_pressed)

	loading_spinner.show()
	# Fetch all levels (we'll sort them client-side)
	CommunityAPI.fetch_levels("new", 100, 0)

func _on_levels_fetched(levels: Array):
	loading_spinner.hide()
	all_levels = levels
	_apply_current_sort()

func _apply_current_sort():
	var sorted_levels = all_levels.duplicate()
	
	_populate_level_list(sorted_levels)

func _populate_level_list(levels: Array):
	# Clear existing cards
	for child in level_list.get_children():
		child.queue_free()

	# Create level cards
	for level_data in levels:
		var card = level_card_scene.instantiate()
		level_list.add_child(card)
		card.setup(level_data)
		card.play_pressed.connect(_on_play_level.bind(level_data["id"]))

func _on_play_level(level_id: String):
	$Black.show()
	
	loading_spinner.show()
	CommunityAPI.fetch_level(level_id)

func _on_level_loaded(level_data: Dictionary):
	loading_spinner.hide()
	# Store level data in singleton for ingame scene to pick up
	CommunityAPI.pending_community_level = level_data
	# Switch to game - the ingame scene will load the community level in _ready()
	get_tree().change_scene_to_file("res://ingame.tscn")

func _on_sort_changed(_index: int):
	_apply_current_sort()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_error(message: String):
	loading_spinner.hide()
	loading_spinner.text = "Error: " + message
	loading_spinner.show()
