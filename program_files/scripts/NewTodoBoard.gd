extends Tabs

onready var new_todo_item = load("res://assets/todo boards/NewTodoItem.tscn")

var items = []

func _ready() -> void:
	var f = File.new()
	if f.file_exists("user://" + name + ".brdtodo"):
		f.open("user://" + name + ".brdtodo", f.READ)
		items = parse_json(f.get_as_text()).items
		for item in items:
			var nti = create_new_item(item.contents, false)
			if item.done_status == true:
				nti.modulate = Color(1,1,1,0.2)
			else:
				nti.modulate = Color(1,1,1,1)

remote func create_new_item(item_contents = "", should_append = true):
	var nti = new_todo_item.instance()
	nti.get_node("Label").text = item_contents
	nti.name = item_contents
	if should_append: items.append(nti.data)
	
	nti.connect("done_status_changed", self, "done_status_changed")
	nti.connect("delete_request", self, "delete_request_received")
	
	$Contents/TodoItems/VBoxContainer.add_child(nti)
	
	save()
	return nti

func done_status_changed(data):
	update_done_status(data)
	rpc("update_done_status", data)
	
func delete_request_received(data, i_name):
	delete_item(data, i_name)
	rpc("delete_item", data, i_name)
	
remote func update_done_status(data):
	var index = items.find(data)
	items[index].done_status = !data.done_status
	save()
	
remote func delete_item(data, i_name):
	items.erase(data)
	$Contents/TodoItems/VBoxContainer.get_node(i_name).queue_free()
	save()

func _on_NewTodoContentsEdit_text_entered(new_text: String) -> void:
	create_new_item($Contents/Toolbar/NewTodoContentsEdit.text)
	rpc("create_new_item", $Contents/Toolbar/NewTodoContentsEdit.text)
	$Contents/Toolbar/NewTodoContentsEdit.text = ""

func _on_AddNewTodoItem_pressed() -> void:
	create_new_item($Contents/Toolbar/NewTodoContentsEdit.text)
	rpc("create_new_item", $Contents/Toolbar/NewTodoContentsEdit.text)
	$Contents/Toolbar/NewTodoContentsEdit.text = ""

func save():
	var data = {
		"items" : items
	}
	var f = File.new()
	f.open("user://" + name + ".brdtodo", f.WRITE)
	f.store_string(JSON.print(data))
	f.close()
