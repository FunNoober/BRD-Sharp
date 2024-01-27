class_name Card
extends VBoxContainer

signal finished_changed(finished : bool, card_name : String)
signal delete_card(card_name : String)

var card_finished : bool = false

func card_init(contents : String, priority : int, finished : bool):
	$buttons/card_button.text = contents
	card_finished = finished
	match priority:
		0:
			$ColorRect.color = Color.GREEN
			$ColorRect/PriorityLabel.text = "Low Priority"
		1:
			$ColorRect.color = Color.YELLOW
			$ColorRect/PriorityLabel.text = "Medium Priority"
		2:
			$ColorRect.color = Color.RED
			$ColorRect/PriorityLabel.text = "High Priority"
	$ColorRect.color.a = (0.1)

func _on_card_button_pressed() -> void:
	card_finished = !card_finished
	finished_changed.emit(card_finished, self.name)
	
func _on_delete_button_pressed() -> void:
	delete_card.emit(self.name)
	queue_free()
