extends HBoxContainer

var data = {
	"contents" : "",
	"done_state" : false,
	"index" : 0
}

signal move_request(done_state, object_name, index)

func _on_MoveItemButton_pressed() -> void:
	if data.done_state == false:
		data.done_state = true
		emit_signal("move_request", data.done_state, name, data.index)
	else:
		data.done_state = false
		emit_signal("move_request", data.done_state, name, data.index)
