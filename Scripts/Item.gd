extends HBoxContainer

var text_to_show : String = ""
var mouse_is_hovering : bool = false
var task_finished : bool = false
var id : int
var uid : String
var path = "user://" + str(id) + ".brd_item"

signal item_deleted

var item_data = {
	"item_text" : text_to_show,
	"task_finished" : task_finished
}

func _ready():
	$Background/Label.text = text_to_show
	item_data.item_text = text_to_show
	path = "user://" + str(id) + ".brd_item"
	var dir = Directory.new()
	if dir.file_exists(path):
		var f = File.new()
		f.open(path, File.READ)
		var c_a_t = f.get_as_text()
		var c_a_d = parse_json(c_a_t)
		item_data = c_a_d
		f.close()
	else:
		save_item_data()

func _on_MoveButton_pressed():
	if task_finished == false:
		var new_parent = get_parent().get_parent().get_parent().get_node("ScrollContainer2").get_node("FinishedContainer")
		get_parent().remove_child(self)
		new_parent.add_child(self)
		task_finished = true
		item_data.task_finished = task_finished
		save_item_data()
	else:
		var new_parent = get_parent().get_parent().get_parent().get_node("ScrollContainer").get_node("NotFinishedContainer")
		get_parent().remove_child(self)
		new_parent.add_child(self)
		task_finished = false
		item_data.task_finished = task_finished
		save_item_data()
		
func save_item_data():
	var f = File.new()
	f.open(path, File.WRITE)
	f.store_string(JSON.print(item_data))
	f.close()

func _on_DeleteButton_pressed() -> void:
	emit_signal("item_deleted")
	var dir = Directory.new()
	dir.open("user://")
	dir.remove(path)
	queue_free()
