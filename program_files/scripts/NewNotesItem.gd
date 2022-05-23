extends Control

signal delete_request(index, contents, object)
var index : int



func _ready() -> void:
	if $HBoxContainer/Label.text.find("http://") != -1 or $HBoxContainer/Label.text.find("https://") != -1:
		$HBoxContainer/OpenLinkButton.show()
	else:
		$HBoxContainer/OpenLinkButton.hide()

func _on_DeleteButton_pressed() -> void:
	$DeleteDialog.popup()

func _on_DeleteDialog_confirmed() -> void:
	emit_signal("delete_request", index, $HBoxContainer/Label.text, self)

func _on_OpenLinkButton_pressed() -> void:
	OS.shell_open($HBoxContainer/Label.text)
