extends HBoxContainer

var data = {
	"contents" : "",
	"done_status" : false
}

signal done_status_changed(data)
signal delete_request(data, i_name)

func _ready() -> void:
	data.contents = $Label.text

func _on_MarkAsDoneButton_pressed() -> void:
	if data.done_status == false:
		data.done_status = true
		modulate = Color(1,1,1,0.2)
		emit_signal("done_status_changed", data)
	else:
		data.done_status = false
		modulate = Color(1,1,1,1)
		emit_signal("done_status_changed", data)


func _on_DeleteButton_pressed() -> void:
	emit_signal("delete_request", data, name)
