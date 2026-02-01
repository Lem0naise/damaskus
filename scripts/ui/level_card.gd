extends PanelContainer

signal play_pressed

@onready var name_label: Label = $HBoxContainer/VBoxContainer/NameLabel
@onready var author_label: Label = $HBoxContainer/VBoxContainer/AuthorLabel
@onready var tags_label: Label = $HBoxContainer/VBoxContainer/TagsLabel
@onready var play_count_label: Label = $HBoxContainer/ActionContainer/PlayCountLabel
@onready var play_button: Button = $HBoxContainer/ActionContainer/PlayButton

var level_id: String

func setup(level_data: Dictionary):
	level_id = level_data["id"]

	name_label.text = level_data["name"]
	author_label.text = "by " + level_data["authorName"]
	play_count_label.text = str(level_data["playCount"]) + " plays"

	if level_data.has("tags") and level_data["tags"].size() > 0:
		tags_label.text = ", ".join(level_data["tags"])
	else:
		tags_label.text = ""

	play_button.pressed.connect(func(): play_pressed.emit())
