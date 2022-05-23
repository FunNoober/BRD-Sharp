extends Tabs

var items_content_array = []

var data_to_store = {
	'items_content_array' : items_content_array,
	'cur_index' : cur_index
}

var cur_index : int = 0

signal delete_request(object, name)

onready var notes_item = load("res://assets/prefabs/NewNotesItem.tscn")

var type = 3

func _on_DeleteBRDButton_pressed() -> void:
	$ConfirmationDialog.popup()

func _on_ConfirmationDialog_confirmed() -> void:
	var dir = Directory.new()
	dir.remove("user://" + self.name + ".brdnotes")
	emit_signal("delete_request", self, self.name)

func create_item(contents, should_append):
	var n = notes_item.instance()
	n.get_node("HBoxContainer/Label").text = contents
	n.connect("delete_request", self, "handle_delete_request")
	if should_append == true:
		items_content_array.append(contents)
	cur_index += 1
	save()
	return n

func create_note_ui():
	var loc_n = create_item($Items/TopBar/NewNoteText.text, true)
	$Items/TopBar/NewNoteText.text = ""
	$Items/Items.add_child(loc_n)
	
func _on_NewNoteText_text_entered(new_text: String) -> void:
	create_note_ui()

func _on_AddNoteButton_pressed() -> void:
	create_note_ui()

func handle_delete_request(index, contents, object):
	items_content_array.erase(contents)
	object.queue_free()
	save()

func save():
	data_to_store.items_content_array = items_content_array
	data_to_store.cur_index = cur_index
	var f = File.new()
	print(name)
	f.open("user://" + name + ".brdnotes", f.WRITE)
	f.store_string(JSON.print(data_to_store))
	f.close()
