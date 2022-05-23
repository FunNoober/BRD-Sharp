extends HBoxContainer

var is_done : bool = false
var index : int
var new_string : String

signal delete_request(index, object)
signal task_state_change(index, is_done, new_string)

func _ready() -> void:
	$Label.bbcode_text = $Label.bbcode_text.replace("[s]", "")

func _on_MarkAsDoneBox_toggled(button_pressed: bool) -> void:
	new_string = $Label.bbcode_text
	is_done = button_pressed
	if is_done == true:
		new_string = new_string.insert(0, "[s]")
		new_string = new_string.insert(len(new_string), '[s]')
		$Label.bbcode_text = new_string
	else:
		new_string = new_string.replace("[s]", "")
		$Label.bbcode_text = new_string
	emit_signal("task_state_change", index, is_done, new_string)

func _on_DeleteButton_pressed() -> void:
	emit_signal("delete_request", index, self)
