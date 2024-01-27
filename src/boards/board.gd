class_name Board
extends MarginContainer

@onready var card_prefab : PackedScene = load("res://cards/card.tscn")

@onready var todo_column : VBoxContainer = $board_contents/columns/todo_column_background/contents/scroll/todo_column
@onready var done_column : VBoxContainer = $board_contents/columns/done_column_background/contents/scroll/done_column

signal card_created(text, priority)
signal card_finished_status_changed(finished_status : bool, card_name : String, board_name : String)
signal card_deleted(card_name : String, board_name : String)
signal board_delete(board_name : String)

func _on_create_card_pressed() -> void:
	var created_card : Card = card_prefab.instantiate()
	var card_name : String = $board_contents/new_card/card_name.text
	
	created_card.card_init(card_name, $board_contents/new_card/card_priority.selected, false)
	created_card.connect("finished_changed", card_finished_changed)
	created_card.connect("delete_card", delete_card)
	$board_contents/columns/todo_column_background/contents/scroll/todo_column.add_child(created_card)
	
	$board_contents/new_card/card_name.text = ""
	card_created.emit(card_name, $board_contents/new_card/card_priority.selected, self.name)
	created_card.name = card_name

func _on_card_name_text_submitted(new_text: String) -> void:
	var created_card : Card = card_prefab.instantiate()
	var card_name : String = $board_contents/new_card/card_name.text
	
	created_card.card_init(card_name, $board_contents/new_card/card_priority.selected, false)
	created_card.connect("finished_changed", card_finished_changed)
	created_card.connect("delete_card", delete_card)
	$board_contents/columns/todo_column_background/contents/scroll/todo_column.add_child(created_card)
	
	$board_contents/new_card/card_name.text = ""
	card_created.emit(card_name, $board_contents/new_card/card_priority.selected, self.name)
	created_card.name = card_name

func card_finished_changed(finished : bool, card_name : String):
	if finished == false:
		done_column.get_node(NodePath(card_name)).reparent(todo_column)
	else:
		todo_column.get_node(NodePath(card_name)).reparent(done_column)
	card_finished_status_changed.emit(finished, card_name, self.name)

func delete_card(card_name : String):
	card_deleted.emit(card_name, self.name)

func _on_delete_board_button_pressed() -> void:
	$ConfirmationDialog.show()

func _on_confirmation_dialog_confirmed() -> void:
	board_delete.emit(self.name)
	queue_free()
