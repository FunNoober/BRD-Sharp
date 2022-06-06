extends Control

#Kanban, Todo, Chat
var boards = [[], [], []]

onready var kanban_board_prefab = load("res://assets/kanban boards/NewKanbanBoard.tscn")
onready var todo_board_prefab = load("res://assets/todo boards/NewTodoBoard.tscn")
onready var chat_board_prefab = load("res://assets/chat boards/NewChatBoard.tscn")

var item_type : int

func _ready() -> void:
	var f = File.new()
	if f.file_exists("user://main.brdsharp"):
		f.open("user://main.brdsharp", f.READ)
		var contents_as_string = f.get_as_text()
		var contents_as_dictionary = parse_json(contents_as_string)
		boards = contents_as_dictionary.boards
		for i in range(len(boards[0])):
			create_new_item(boards[0][i], false, 0)
		for i in range(len(boards[2])):
			create_new_item(boards[2][i], false, 3)
		for i in range(len(boards[1])):
			create_new_item(boards[1][i], false, 1)
		f.close()

remote func create_new_item(new_item_name, should_save, type):
	if type == 0:
		var new_kbp = kanban_board_prefab.instance()
		new_kbp.name = new_item_name
		$Contents/TabContainer.add_child(new_kbp)
		boards[0].append(new_kbp.name)
		if should_save: save();
	if type == 3:
		var new_cb = chat_board_prefab.instance()
		new_cb.name = new_item_name
		$Contents/TabContainer.add_child(new_cb)
		boards[2].append(new_cb.name)
		if should_save: save();
	if type == 1:
		var new_todo_board = todo_board_prefab.instance()
		new_todo_board.name = new_item_name
		$Contents/TabContainer.add_child(new_todo_board)
		boards[1].append(new_todo_board.name)
		if should_save: save();

func _on_BRDTypeEdit_item_selected(index: int) -> void:
	item_type = index

func _on_BRDNameEdit_text_entered(_new_text: String) -> void:
	create_new_item($Contents/AddBRDBar/BRDNameEdit.text, true, item_type)
	rpc("create_new_item", $Contents/AddBRDBar/BRDNameEdit.text, true, item_type)
	$Contents/AddBRDBar/BRDNameEdit.text = ""

func _on_AddBRD_pressed() -> void:
	create_new_item($Contents/AddBRDBar/BRDNameEdit.text, true, item_type)
	rpc("create_new_item", $Contents/AddBRDBar/BRDNameEdit.text, false, item_type)
	$Contents/AddBRDBar/BRDNameEdit.text = ""

func _on_HostButton_pressed() -> void:
	var host = NetworkedMultiplayerENet.new()
	host.create_server(3534)
	get_tree().network_peer = host
	$Contents/Toolbar/JoinButton.hide()
	
func _on_JoinButton_pressed() -> void:
	var host = NetworkedMultiplayerENet.new()
	host.create_client($Contents/Toolbar/IPEdit.text, 3534)
	get_tree().network_peer = host
	$Contents/Toolbar/HostButton.hide()

func save():
	var data_to_store = {
		"boards" : boards
	}
	var f = File.new()
	f.open("user://main.brdsharp", f.WRITE)
	f.store_string(JSON.print(data_to_store))
	f.close()
