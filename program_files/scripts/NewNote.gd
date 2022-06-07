extends HBoxContainer

var data = {
	"contents" : ""
}

signal delete_request(data, i_name)

func _ready() -> void:
	$NoteContents.text = data.contents
	if data.contents.find("http") != -1:
		$OpenLinkButton.show()
	else:
		$OpenLinkButton.hide()

func _on_DeleteButton_pressed() -> void:
	emit_signal("delete_request", data, name)


func _on_OpenLinkButton_pressed() -> void:
	OS.shell_open(data.contents)
