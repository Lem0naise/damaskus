extends Node

signal mobile_controls_changed(is_enabled: bool)

var mobile_controls_enabled: bool = false:
	set(value):
		mobile_controls_enabled = value
		mobile_controls_changed.emit(value)
		if not _is_loading:
			save_settings()

const SETTINGS_PATH = "user://game_settings.cfg"
var _is_loading: bool = false

func _ready() -> void:
	load_settings()

func toggle_mobile_controls() -> void:
	print("gamesettings: i have been toggled: ", mobile_controls_enabled)
	mobile_controls_enabled = !mobile_controls_enabled
	print("to this: ", mobile_controls_enabled)

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("controls", "mobile_enabled", mobile_controls_enabled)
	config.save(SETTINGS_PATH)

func load_settings() -> void:
	_is_loading = true
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	if err == OK:
		mobile_controls_enabled = config.get_value("controls", "mobile_enabled", false)
	_is_loading = false
