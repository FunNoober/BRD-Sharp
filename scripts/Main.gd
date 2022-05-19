extends Control

var brd_name_array = []
var data_to_store = {
	'brd_name_array' : brd_name_array
}

onready var BRD_PREFAB = load("res://assets/prefabs/NewBRD.tscn")

const brd_main_path = "user://main.brds"

func _ready() -> void:
	$MainContainer/ColorBlindFriendlyButton.pressed = ColorBlindFriendly.color_blind_enabled
	set_colorblind_theme()
	var d = Directory.new()
	if d.file_exists(brd_main_path):
		var f = File.new()
		f.open(brd_main_path, f.READ)
		var contents_as_text = f.get_as_text()
		var contents_as_dictionary = parse_json(contents_as_text)
		data_to_store = contents_as_dictionary
		brd_name_array = data_to_store.brd_name_array
		for i in range(len(brd_name_array)):
			var b = BRD_PREFAB.instance()
			b.set_name(brd_name_array[i])
			$MainContainer/BRDTabs.add_child(b)
			
	
func _on_AddBRDButton_pressed() -> void:
	var b = BRD_PREFAB.instance()
	b.set_name($MainContainer/TopMainBar/NewBRDText.text)
	brd_name_array.append($MainContainer/TopMainBar/NewBRDText.text)
	$MainContainer/BRDTabs.add_child(b)
	$MainContainer/TopMainBar/NewBRDText.text = ''
	save()

func save():
	data_to_store.brd_name_array = brd_name_array
	var f = File.new()
	f.open(brd_main_path, f.WRITE)
	f.store_string(JSON.print(data_to_store))
	f.close()

func set_colorblind_theme():
	ColorBlindFriendly.color_blind_enabled = $MainContainer/ColorBlindFriendlyButton.pressed
	if ColorBlindFriendly.color_blind_enabled == true:
		self.theme = ColorBlindFriendly.color_blind_theme
	else:
		self.theme = ColorBlindFriendly.regular_theme
	ColorBlindFriendly.save()

func _on_ColorBlindFriendlyButton_pressed() -> void:
	set_colorblind_theme()
