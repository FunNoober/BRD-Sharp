extends HBoxContainer

var is_done : bool
var index : int

signal move_request(is_done, index, object)
signal delete_request(index, object)

func _ready() -> void:
	if $Contents.text.find("https") != -1:
		$OpenButton.show()
	else:
		$OpenButton.hide()

func _on_MoveButton_pressed() -> void:
	emit_signal("move_request", is_done, index, self)

func _on_OpenButton_pressed() -> void:
	OS.shell_open($Contents.text)

func _on_DeleteButton_pressed() -> void:
	emit_signal("delete_request", index, self)
