extends Tabs

var items_name_array = []
var items_complete_array = []
var items_description_array = []
var items_id_array = []

var data_to_store = {
	'items_complete_array' : items_complete_array,
	'items_name_array' : items_name_array,
	'items_id_array' : items_id_array,
	'items_description_array' : items_description_array,
	'cur_index' : cur_index
}

onready var new_item = load("res://assets/prefabs/NewItem.tscn")
onready var todo_column = get_node("VBoxContainer/Columns/ToDoColumnScrollContainer/ToDoColumn")
onready var done_column = get_node("VBoxContainer/Columns/DoneColumnScrollContainer/DoneColumn")
var cur_index : int = 0

signal delete_request(object, name)

func _ready() -> void:
	var d = Directory.new()
	if d.file_exists("user://" + name + ".brd"):
		var f = File.new()
		f.open("user://" + name + ".brd", f.READ)
		var contents_as_text = f.get_as_text()
		var contents_as_dictionary = parse_json(contents_as_text)
		data_to_store = contents_as_dictionary
		
		items_name_array = data_to_store.items_name_array
		items_complete_array = data_to_store.items_complete_array
		items_id_array = data_to_store.items_id_array
		items_description_array = data_to_store.items_description_array
		cur_index = data_to_store.cur_index
		
		for i in range(todo_column.get_child_count()):
			todo_column.get_child(i).queue_free()
		for i in range(done_column.get_child_count()):
			done_column.get_child(i).queue_free()
		
		for i in range(len(items_name_array)):
			var loc_i = create_new_item(items_name_array[i], false)
			loc_i.index = items_id_array[i]
			loc_i.description = items_description_array[i]
			if items_complete_array[i] == false:
				loc_i.is_done = false
				todo_column.add_child(loc_i)
			else:
				loc_i.is_done = true
				done_column.add_child(loc_i)
			
func create_new_item(contents, should_append):
	var i = new_item.instance()
	i.get_node("Control/ScrollContainer/Contents").text = contents
	i.description = $VBoxContainer/HBoxContainer2/NewDecriptionText.text
	i.index = cur_index
	if should_append == true:
		items_name_array.append(contents)
		items_complete_array.append(i.is_done)
		items_id_array.append(cur_index)
		items_description_array.append(i.description)
		cur_index += 1
	$VBoxContainer/HBoxContainer/NewItemText.text = ''
	$VBoxContainer/HBoxContainer2/NewDecriptionText.text = ''
	save()
	i.connect("move_request", self, "recieve_move_request")
	i.connect("delete_request", self, "recieve_delete_request")
	return i

func _on_AddItemButton_pressed() -> void:
	var loc_i = create_new_item($VBoxContainer/HBoxContainer/NewItemText.text, true)
	todo_column.add_child(loc_i)
	
func save():
	data_to_store.items_complete_array = items_complete_array
	data_to_store.items_name_array = items_name_array
	data_to_store.items_id_array = items_id_array
	data_to_store.items_description_array = items_description_array
	data_to_store.cur_index = cur_index
	var f = File.new()
	f.open("user://" + name + ".brd", f.WRITE)
	f.store_string(JSON.print(data_to_store))
	f.close()

func recieve_move_request(status, id, object):
	if status == true:
		items_complete_array[id] = false
		object.is_done = false
		done_column.remove_child(object)
		todo_column.add_child(object)
	if status == false:
		items_complete_array[id] = true
		object.is_done = true
		todo_column.remove_child(object)
		done_column.add_child(object)
	save()
	pass

func recieve_delete_request(id, object):
	cur_index -= 1
	items_id_array.erase(id)
	items_complete_array.erase(object.is_done)
	items_name_array.erase(object.get_node('Control/ScrollContainer/Contents').text)
	items_description_array.erase(object.description)
	save()
	object.queue_free()
	pass


func _on_DeleteBRDButton_pressed() -> void:
	$ConfirmationDialog.popup()


func _on_ConfirmationDialog_confirmed() -> void:
	var dir = Directory.new()
	dir.remove("user://" + self.name + ".brd")
	emit_signal("delete_request", self, self.name)


func _on_NewItemText_text_entered(new_text: String) -> void:
	var loc_i = create_new_item($VBoxContainer/HBoxContainer/NewItemText.text, true)
	todo_column.add_child(loc_i)


func _on_NewDecriptionText_text_entered(new_text: String) -> void:
	var loc_i = create_new_item($VBoxContainer/HBoxContainer/NewItemText.text, true)
	todo_column.add_child(loc_i)
