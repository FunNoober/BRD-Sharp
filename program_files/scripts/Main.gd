extends Control

var brd_name_array = []
var checklist_name_array = []
var notes_name_array = []
var data_to_store = {
	'brd_name_array' : brd_name_array,
	'checklist_name_array' : checklist_name_array,
	'notes_name_array' : notes_name_array
}

onready var BRD_PREFAB = load("res://assets/prefabs/NewBRD.tscn")
onready var CHECKLIST_PREFAB = load("res://assets/prefabs/NewToDoList.tscn")
onready var NOTES_PREFAB = load("res://assets/prefabs/NewNotesList.tscn")

const brd_main_path = "user://main.brds"

var type : int = 0

func _ready() -> void:
	$MainContainer/BottomToolBar/ColorBlindFriendlyButton.pressed = ColorBlindFriendly.color_blind_enabled
	set_colorblind_theme()
	var d = Directory.new()
	if d.file_exists(brd_main_path):
		var f = File.new()
		f.open(brd_main_path, f.READ)
		var contents_as_text = f.get_as_text()
		var contents_as_dictionary = parse_json(contents_as_text)
		data_to_store = contents_as_dictionary
		brd_name_array = data_to_store.brd_name_array
		checklist_name_array = data_to_store.checklist_name_array
		notes_name_array = data_to_store.notes_name_array
		for i in range(len(brd_name_array)):
			create_starndard_brd(false, brd_name_array[i])
		for i in range(len(checklist_name_array)):
			create_checklist_brd(false, checklist_name_array[i])
		for i in range(len(notes_name_array)):
			create_notes_brd(false, notes_name_array[i])
	
func _on_AddBRDButton_pressed() -> void:
	if type == 0:
		create_starndard_brd(true, $MainContainer/TopMainBar/NewBRDText.text)
	if type == 1:
		create_checklist_brd(true, $MainContainer/TopMainBar/NewBRDText.text)
	if type == 2:
		create_notes_brd(true, $MainContainer/TopMainBar/NewBRDText.text)

func create_starndard_brd(should_append, name):
	var b = BRD_PREFAB.instance()
	b.set_name(name)
	if should_append == true:
		brd_name_array.append(name)
	b.connect("delete_request", self, "recieve_delete_request")
	$MainContainer/BRDTabs.add_child(b)
	$MainContainer/TopMainBar/NewBRDText.text = ''
	save()
	
func create_checklist_brd(should_append, name):
	var b = CHECKLIST_PREFAB.instance()
	b.set_name(name)
	if should_append == true:
		checklist_name_array.append(name)
	b.connect("delete_request", self, "recieve_delete_request")
	$MainContainer/BRDTabs.add_child(b)
	$MainContainer/TopMainBar/NewBRDText.text = ''
	save()
	
func create_notes_brd(should_append, name):
	var b = NOTES_PREFAB.instance()
	b.set_name(name)
	if should_append == true:
		notes_name_array.append(name)
	b.connect("delete_request", self, "recieve_delete_request")
	$MainContainer/BRDTabs.add_child(b)
	$MainContainer/TopMainBar/NewBRDText.text = ''

func save():
	data_to_store.brd_name_array = brd_name_array
	data_to_store.checklist_name_array = checklist_name_array
	data_to_store.notes_name_array = notes_name_array
	var f = File.new()
	f.open(brd_main_path, f.WRITE)
	f.store_string(JSON.print(data_to_store))
	f.close()

func set_colorblind_theme():
	ColorBlindFriendly.color_blind_enabled = $MainContainer/BottomToolBar/ColorBlindFriendlyButton.pressed
	if ColorBlindFriendly.color_blind_enabled == true:
		self.theme = ColorBlindFriendly.color_blind_theme
	else:
		self.theme = ColorBlindFriendly.regular_theme
	ColorBlindFriendly.save()

func _on_ColorBlindFriendlyButton_pressed() -> void:
	set_colorblind_theme()

func recieve_delete_request(object, name):
	if object.type == 1:
		brd_name_array.erase(name)
	if object.type == 2:
		checklist_name_array.erase(name)
	if object.type == 3:
		notes_name_array.erase(name)
	save()
	object.queue_free()
	
func _on_NewBRDText_text_entered(new_text: String) -> void:
	if type == 0:
		create_starndard_brd(true, $MainContainer/TopMainBar/NewBRDText.text)
	if type == 1:
		create_checklist_brd(true, $MainContainer/TopMainBar/NewBRDText.text)
	if type == 2:
		create_notes_brd(true, $MainContainer/TopMainBar/NewBRDText.text)

func _on_TypeButton_item_selected(index: int) -> void:
	type = index
