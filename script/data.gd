class_name Data
extends Node

const user_data:String = "user://save.json"

var data:Dictionary = {
	"record": 0
}

func get_data():
	var parse_result
	var file = FileAccess.open(user_data, FileAccess.READ)
	var json_data = JSON.new()
	if file != null:
		json_data.parse(file.get_as_text())
		parse_result = json_data.get_data()
	else:
		parse_result = data
	return parse_result

static func save_data(data:Dictionary) -> void:
	var file = FileAccess.open(user_data, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
