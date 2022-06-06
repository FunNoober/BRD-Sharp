extends Tabs

onready var new_kanban_item = load("res://assets/kanban boards/NewKanbanItem.tscn")

var items = []

var cur_index : int

onready var done_column = get_node("Contents/Items/HSplitContainer/DoneScroll/VBoxContainer")
onready var todo_column = get_node("Contents/Items/HSplitContainer/TodoScroll/VBoxContainer")

func _ready() -> void:
	var f = File.new()
	if f.file_exists("user://" + name + ".brd"):
		f.open("user://" + name + ".brd", f.READ)
		items = parse_json(f.get_as_text()).items
		cur_index = parse_json(f.get_as_text()).cur_index
		for i in range(len(items)):
			create_new_item(items[i].contents, false, items[i].done_state)

remote func create_new_item(item_name, should_append, done_by_default):
	var nki = new_kanban_item.instance()
	nki.name = item_name
	nki.get_node("ItemContentsButton").text = item_name
	nki.data.contents = item_name
	
	nki.connect("move_request", self, "move_item")
	nki.connect("delete_request", self, "delete_item")
	
	if done_by_default == false: todo_column.add_child(nki);
	else: done_column.add_child(nki);
	
	if should_append == true: 
		items.append(nki.data)
		cur_index += 1
		nki.data.index = cur_index
	save()
	
func move_item(done_state, object_name, index):
	receive_item_move_request(done_state, object_name, index)
	rpc("receive_item_move_request", done_state, object_name, index)
	
func delete_item(data, done_state, object_name):
	handle_delete_request(data, done_state, object_name)
	rpc("handle_delete_request", data, done_state, object_name)
	
remote func receive_item_move_request(done_state, object_name, index):
	var todo_container = $Contents/Items/HSplitContainer/TodoScroll/VBoxContainer
	var done_container = $Contents/Items/HSplitContainer/DoneScroll/VBoxContainer
	if done_state == true:
		var object = get_node("Contents/Items/HSplitContainer/TodoScroll/VBoxContainer" + "/" + object_name)
		todo_container.remove_child(object)
		done_container.add_child(object)
	else:
		var object = get_node("Contents/Items/HSplitContainer/DoneScroll/VBoxContainer" + "/" + object_name)
		done_container.remove_child(object)
		todo_container.add_child(object)
	items[index-1].done_state = done_state
	save()
	
remote func handle_delete_request(data, done_state, object_name):
	items.erase(data)
	if done_state == true:
		get_node("Contents/Items/HSplitContainer/DoneScroll/VBoxContainer" + "/" + object_name).queue_free()
	if done_state == false:
		get_node("Contents/Items/HSplitContainer/TodoScroll/VBoxContainer" + "/" + object_name).queue_free()
	save()

func call_create_new_item():
	create_new_item($Contents/Toolbar/NewKanbanItemNameEdit.text, true, false)
	rpc("create_new_item", $Contents/Toolbar/NewKanbanItemNameEdit.text, true, false)
	$Contents/Toolbar/NewKanbanItemNameEdit.text = ""

func _on_NewKanbanItemNameEdit_text_entered(_new_text: String) -> void:
	call_create_new_item()

func _on_NewKanbanItemDescriptionEdit_text_entered(_new_text: String) -> void:
	call_create_new_item()

func _on_AddKanbanItem_pressed() -> void:
	call_create_new_item()

func save():
	var data = {
		"items" : items,
		"cur_index" : cur_index
	}
	var f = File.new()
	f.open("user://" + name + ".brd", f.WRITE)
	f.store_string(JSON.print(data))
	f.close()
