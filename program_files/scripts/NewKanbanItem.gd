extends HBoxContainer

var data = {
	"contents" : "",
	"description" : "",
	"done_state" : false,
	"index" : 0
}

signal move_request(done_state, object_name, index)
signal delete_request(data, done_state, object_name)

func _on_MoveItemButton_pressed() -> void:
	if data.done_state == false:
		data.done_state = true
		emit_signal("move_request", data.done_state, name, data.index)
	else:
		data.done_state = false
		emit_signal("move_request", data.done_state, name, data.index)

func _on_DeleteItemButton_pressed() -> void:
	emit_signal("delete_request", data, data.done_state, name)

func _on_ItemContentsButton_pressed() -> void:
	$AcceptDialog.popup()
	$AcceptDialog.dialog_text = data.description
