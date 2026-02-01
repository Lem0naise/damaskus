extends Node

const API_BASE_URL = "http://automation.112000000.xyz/webhook"
const API_AUTH_TOKEN = "9JnwJyoeqJ6E8bRf"

signal levels_fetched(levels: Array)
signal level_loaded(level_data: Dictionary)
signal error_occurred(message: String)

var http_request: HTTPRequest
var pending_request_type: String = ""
var pending_community_level: Dictionary = {} # Store level data to load after scene change

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

# Helper to get headers with authorization
func _get_headers() -> Array:
	return ["Authorization: " + API_AUTH_TOKEN]

# Fetch list of levels
func fetch_levels(sort: String = "popular", limit: int = 20, offset: int = 0):
	var url = "%s/levels?sort=%s&limit=%d&offset=%d" % [API_BASE_URL, sort, limit, offset]
	pending_request_type = "levels_list"
	var error = http_request.request(url, _get_headers())
	if error != OK:
		error_occurred.emit("Failed to connect to server")

# Fetch single level
func fetch_level(level_id: String):
	var url = "%s/levels/specificlevel" % [API_BASE_URL]
	pending_request_type = "level_detail"
	
	# Prepare JSON body
	var body = JSON.stringify({"levelId": level_id})
	
	# Add Content-Type header for JSON
	var headers = _get_headers() + ["Content-Type: application/json"]
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		error_occurred.emit("Failed to load level")


# Handle responses
func _on_request_completed(_result: int, response_code: int, _headers: Array, body: PackedByteArray):
	if response_code != 200 and response_code != 201:
		error_occurred.emit("Server error: %d" % response_code)
		return

	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())

	if parse_result != OK:
		error_occurred.emit("Invalid server response")
		return

	var data = json.get_data()

	# Route based on request type
	match pending_request_type:
		"levels_list":
			if data.has("levels"):
				levels_fetched.emit(data["levels"])
		"level_detail":
			if data.has("level"):
				level_loaded.emit(data["level"])

	pending_request_type = ""
