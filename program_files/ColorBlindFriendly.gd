extends Node


var regular_theme = load("res://assets/themes/MainTheme.tres")
var color_blind_theme = load("res://assets/themes/ColorBlindTheme.tres")

var color_blind_enabled : bool

var data_to_store = {
	'color_blind_enabled' : color_blind_enabled
}

func _ready() -> void:
	var d = Directory.new()
	if d.file_exists("user://colorblind.json"):
		var f = File.new()
		f.open("user://colorblind.json", f.READ)
		var contents_as_string = f.get_as_text()
		var contents_as_dictionary = parse_json(contents_as_string)
		data_to_store = contents_as_dictionary
		color_blind_enabled = data_to_store.color_blind_enabled
		f.close()
		
func save():
	data_to_store.color_blind_enabled = color_blind_enabled
	var f = File.new()
	f.open("user://colorblind.json", f.WRITE)
	f.store_string(JSON.print(data_to_store))
	f.close()
