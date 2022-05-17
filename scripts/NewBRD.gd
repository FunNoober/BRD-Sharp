extends Tabs

var items_name_array = []
var items_complete_array = []
var items_id_array = []

var data_to_store = {
	'items_complete_array' : items_complete_array,
	'items_name_array' : items_name_array,
	'items_id_array' : items_id_array,
	'cur_index' : cur_index
}

onready var new_item = load("res://assets/prefabs/NewItem.tscn")
var cur_index : int

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
		cur_index = data_to_store.cur_index
		
		for i in range($VBoxContainer/Columns/ToDoColumn.get_child_count()):
			$VBoxContainer/Columns/ToDoColumn.get_child(i).queue_free()
		for i in range($VBoxContainer/Columns/DoneColumn.get_child_count()):
			$VBoxContainer/Columns/DoneColumn.get_child(i).queue_free()
		
		for i in range(len(items_name_array)):
			var loc_i = create_new_item(items_name_array[i], false)
			loc_i.index = items_id_array[i]
			if items_complete_array[i] == false:
				loc_i.is_done = false
				$VBoxContainer/Columns/ToDoColumn.add_child(loc_i)
			else:
				loc_i.is_done = true
				$VBoxContainer/Columns/DoneColumn.add_child(loc_i)
			
func create_new_item(contents, should_append):
	var i = new_item.instance()
	i.get_node("Contents").text = contents
	if should_append == true:
		cur_index += 1
		items_name_array.append(contents)
		items_complete_array.append(i.is_done)
		items_id_array.append(cur_index)
	i.index = cur_index
	$VBoxContainer/HBoxContainer/NewItemText.text = ''
	save()
	i.connect("move_request", self, "recieve_move_request")
	i.connect("delete_request", self, "recieve_delete_request")
	return i

func _on_AddItemButton_pressed() -> void:
	var loc_i = create_new_item($VBoxContainer/HBoxContainer/NewItemText.text, true)
	$VBoxContainer/Columns/ToDoColumn.add_child(loc_i)
	
func save():
	data_to_store.items_complete_array = items_complete_array
	data_to_store.items_name_array = items_name_array
	data_to_store.items_id_array = items_id_array
	data_to_store.cur_index = cur_index
	var f = File.new()
	f.open("user://" + name + ".brd", f.WRITE)
	f.store_string(JSON.print(data_to_store))
	f.close()

func recieve_move_request(status, id, object):
	if status == true:
		items_complete_array[id-1] = false
		object.is_done = false
		$VBoxContainer/Columns/DoneColumn.remove_child(object)
		$VBoxContainer/Columns/ToDoColumn.add_child(object)
	if status == false:
		items_complete_array[id-1] = true
		object.is_done = true
		$VBoxContainer/Columns/ToDoColumn.remove_child(object)
		$VBoxContainer/Columns/DoneColumn.add_child(object)
	save()
	pass

func recieve_delete_request(id, object):
	items_complete_array.pop_at(id-1)
	items_name_array.pop_at(id-1)
	items_id_array.pop_at(id-1)
	cur_index -= 1
	for i in range(len(items_id_array)):
		items_id_array[i] -= 1
	object.queue_free()
	save()
	pass
