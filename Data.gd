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

static func get_files_name_path(path : String) -> Array:
	var files:Array = []
	var filesPath = DirAccess.get_files_at(path)
	if filesPath.size() > 0:
		for i in filesPath:
			files.append(path + i)
	return files

static func folder_create(path) -> void:
	DirAccess.make_dir_absolute(path)

static func folder_remove(path) -> void:
	DirAccess.remove_absolute(path)

static func str_to_vec2(string := "") -> Vector2:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")
		return Vector2(int(array[0]), int(array[1]))
	return Vector2.ZERO
