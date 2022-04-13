extends Control

var new_item = load("res://Scenes and Prefabs/Item.tscn")

var id : int

var global_data = {
	global_id = id
}

func _ready() -> void:
	var dir = Directory.new()
	if dir.file_exists("user://" + "board.brd_file"):
		var f = File.new()
		f.open("user://" + "board.brd_file", File.READ)
		var c_a_t = f.get_as_text()
		var c_a_d = parse_json(c_a_t)
		var data_dic = c_a_d
		id = data_dic.global_id
		f.close()
		
		for i in range(id):
			var f1 = File.new()
			f1.open("user://" + str(i) + ".brd_item", File.READ)
			var c_a_t_1 = f1.get_as_text()
			var c_a_d_1 = parse_json(c_a_t_1)
			if c_a_d_1.task_finished == true:
				var created_item = new_item.instance()
				created_item.text_to_show = c_a_d_1.item_text
				$Containers/ScrollContainer2/FinishedContainer.add_child(created_item)
			else:
				var created_item = new_item.instance()
				created_item.text_to_show = c_a_d_1.item_text
				$Containers/ScrollContainer/NotFinishedContainer.add_child(created_item)
			f1.close()
	else:
		save_board_data()
		

func _on_AddItemButotn_pressed():
	var created_item = new_item.instance()
	created_item.text_to_show = $TopSectionContainer/NewItemText.text
	created_item.id = id
	created_item.connect("item_deleted", self, "update_data")
	id += 1
	
	global_data.global_id = id
	save_board_data()
	
	$Containers/ScrollContainer/NotFinishedContainer.add_child(created_item)

func save_board_data():
	var f = File.new()
	f.open("user://" + "board.brd_file", File.WRITE)
	f.store_string(JSON.print(global_data))
	f.close()
	
func update_data():
	id -= 1
	global_data.global_id = id
	save_board_data()
