extends HBoxContainer

var data = {
	"contents" : "",
	"done_status" : false
}

signal done_status_changed(data, i_name)
signal delete_request(data, i_name)

func _ready() -> void:
	data.contents = $Label.text

func _on_MarkAsDoneButton_pressed() -> void:
	emit_signal("done_status_changed", data, name)

func _on_DeleteButton_pressed() -> void:
	emit_signal("delete_request", data, name)
