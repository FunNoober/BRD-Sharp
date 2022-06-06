extends Tabs

onready var new_todo_item = load("res://assets/todo boards/NewTodoItem.tscn")

var items = []

remote func create_new_item(item_contents = ""):
	var nti = new_todo_item.instance()
	nti.get_node("Label").text = item_contents
	nti.name = item_contents
	items.append(nti.data)
	
	nti.connect("done_status_changed", self, "done_status_changed")
	nti.connect("delete_request", self, "delete_request_received")
	
	$Contents/TodoItems/VBoxContainer.add_child(nti)
	$Contents/Toolbar/NewTodoContentsEdit.text = ""
	save()

func done_status_changed(data):
	update_done_status(data)
	rpc("update_done_status", data)
	
func delete_request_received(data, i_name):
	delete_item(data, i_name)
	rpc("delete_item", data, i_name)
	
remote func update_done_status(data):
	var index = items.find(data)
	items[index].done_status = data.done_status
	save()
	
remote func delete_item(data, i_name):
	items.erase(data)
	$Contents/TodoItems/VBoxContainer.get_node(i_name).queue_free()
	save()

func _on_NewTodoContentsEdit_text_entered(new_text: String) -> void:
	create_new_item($Contents/Toolbar/NewTodoContentsEdit.text)
	rpc("create_new_item", $Contents/Toolbar/NewTodoContentsEdit.text)

func _on_AddNewTodoItem_pressed() -> void:
	create_new_item($Contents/Toolbar/NewTodoContentsEdit.text)
	rpc("create_new_item", $Contents/Toolbar/NewTodoContentsEdit.text)

func save():
	var data = {
		"items" : items
	}
	var f = File.new()
	f.open("user://" + name + ".brdtodo", f.WRITE)
	f.store_string(JSON.print(data))
	f.close()
