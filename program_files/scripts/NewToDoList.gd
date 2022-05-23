extends Tabs

var items_name_array = []

var data_to_store = {
	'items_array' : items_name_array,
	'cur_index' : cur_index
}

var cur_index : int = 0

onready var new_item = load("res://assets/prefabs/NewToDoItem.tscn")

signal delete_request(object, name)

func _ready() -> void:
	var d = Directory.new()
	if d.file_exists("user://" + name + ".brdchecklist"):
		var f = File.new()
		f.open("user://" + name + ".brdchecklist", f.READ)
		var contents_as_text = f.get_as_text()
		var contents_as_dictionary = parse_json(contents_as_text)
		data_to_store = contents_as_dictionary
		items_name_array = data_to_store.items_array
		cur_index = data_to_store.cur_index
		for i in range (len(items_name_array)):
			#ToDo: When instancing in new items on ready, set their bbcode to the correct thing as well
			var loc_i = create_new_item(items_name_array[i], false)
			$Items/Items.add_child(loc_i)
			save()

func save():
	data_to_store.items_array = items_name_array
	data_to_store.cur_index = cur_index
	var f = File.new()
	f.open("user://" + name + ".brdchecklist", f.WRITE)
	f.store_string(JSON.print(data_to_store))
	f.close()

func _on_DeleteBRDButton_pressed() -> void:
	$ConfirmationDialog.popup()

func create_new_item(contents, should_append):
	var i = new_item.instance()
	i.get_node("Label").bbcode_text = contents
	i.index = cur_index
	if should_append == true:
		items_name_array.append(contents)
		cur_index += 1
	$Items/TopBar/NewToDoText.text = ''
	i.connect("delete_request", self, "handle_delete_request")
	i.connect("task_state_change", self, "handle_task_state_changed")
	save()
	return i

func handle_delete_request(index, object):
	items_name_array.erase(object.get_node("Label").bbcode_text)
	object.queue_free()
	cur_index -= 1
	save()
	
func handle_task_state_changed(index, is_done, new_string):
	# WE are not reversing the order so if we are done then remove old string without bbcode then add in new, unaltered string.
	#If we are not done then remove old string with bbcode then add in new string
	if is_done == true:
		items_name_array.erase(new_string.replace("[s]", ""))
		items_name_array.append(new_string)
	if is_done == false:
		var new_loc_string = "[s]" + new_string + "[s]"
		
		print(new_loc_string)
		items_name_array.erase(new_loc_string)
		items_name_array.append(new_string.replace("[s]", ""))
	save()

func _on_ConfirmationDialog_confirmed() -> void:
	var dir = Directory.new()
	dir.remove("user://" + self.name + ".brd")
	emit_signal("delete_request", self, self.name)

func _on_NewToDoText_text_entered(new_text: String) -> void:
	var loc_i = create_new_item($Items/TopBar/NewToDoText.text, true)
	$Items/Items.add_child(loc_i)

func _on_AddToDoButton_pressed() -> void:
	var loc_i = create_new_item($Items/TopBar/NewToDoText.text, true)
	$Items/Items.add_child(loc_i)
