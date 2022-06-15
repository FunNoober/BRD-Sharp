extends Tabs

var items = []

onready var new_note = load("res://assets/note boards/NewNote.tscn")

signal delete_request(i_name)

func _ready() -> void:
	var f = File.new()
	if f.file_exists("user://" + name + ".brdnotes"):
		f.open("user://" + name + ".brdnotes", f.READ)
		items = parse_json(f.get_as_text()).items
		for item in items:
			create_note(false, item)

remote func create_note(should_append, contents):
	var nn = new_note.instance()
	nn.data.contents = contents
	nn.name = contents
	nn.connect("delete_request", self, "handle_delete_request")
	if should_append == true: items.append(nn.data.contents)
	$Contents/Items/VBoxContainer.add_child(nn)
	save()
	
func handle_delete_request(data, i_name):
	delete_note(data, i_name)
	rpc("delete_note", data, i_name)
	
remote func delete_note(data, i_name):
	items.erase(data.contents)
	get_node("Contents/Items/VBoxContainer" + "/" + i_name).queue_free()
	save()
	
func _on_NoteContentsEdit_text_entered(new_text: String) -> void:
	create_note(true, $Contents/Toolbar/NoteContentsEdit.text)
	rpc("create_note", true, $Contents/Toolbar/NoteContentsEdit.text)
	$Contents/Toolbar/NoteContentsEdit.text = ""

func _on_CreateNote_pressed() -> void:
	create_note(true, $Contents/Toolbar/NoteContentsEdit.text)
	rpc("create_note", true, $Contents/Toolbar/NoteContentsEdit.text)
	$Contents/Toolbar/NoteContentsEdit.text = ""

func save():
	var data = {
		"items" : items
	}
	print(data.items)
	var f = File.new()
	f.open("user://" + name + ".brdnotes", f.WRITE)
	f.store_string(JSON.print(data))
	f.close()

func _on_DeleteBoardButton_pressed() -> void:
	emit_signal("delete_request", name)
	queue_free()
