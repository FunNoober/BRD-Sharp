extends Control

var boards : Array = []

@onready var board_prefab : PackedScene = load("res://boards/board.tscn")
@onready var card_prefab : PackedScene = load("res://cards/card.tscn")

var board_file = ConfigFile.new()

func _ready() -> void:
	var err = board_file.load("boards.brds")
	
	if err != OK:
		return
		
	boards = board_file.get_value("board", "boards", {})
	for board in boards:
		var created_board : Board = board_prefab.instantiate()
		created_board.name = board.name
		$margain/interface_elements/tabs.add_child(created_board)
		created_board.connect("card_created", card_created)
		created_board.connect("card_finished_status_changed", card_finished_changed)
		created_board.connect("card_deleted", card_deleted)
		created_board.connect("board_delete", board_delete)
		for card in board.cards:
			var created_card : Card = card_prefab.instantiate()
			created_card.card_init(card.contents, card.priority, card.finished)
			if card.finished:
				created_board.done_column.add_child(created_card)
			else:
				created_board.todo_column.add_child(created_card)
			created_card.connect("finished_changed", created_board.card_finished_changed)
			created_card.connect("delete_card", created_board.delete_card)
			created_card.name = card.contents

func _on_create_board_pressed() -> void:
	var new_board : Board = board_prefab.instantiate()
	new_board.name = %board_name.text
	$margain/interface_elements/tabs.add_child(new_board)
	boards.append({
		"name": new_board.name,
		"cards": []
	})
	
	%board_name.text = ""
	new_board.connect("card_created", card_created)
	new_board.connect("card_finished_status_changed", card_finished_changed)
	new_board.connect("card_deleted", card_deleted)
	new_board.connect("board_delete", board_delete)
	$margain/interface_elements/tabs.current_tab = $margain/interface_elements/tabs.get_children().size()
	board_file.set_value("board", "boards", boards)
	board_file.save("boards.brds")
	
func _on_board_name_text_submitted(new_text: String) -> void:
	var new_board : Board = board_prefab.instantiate()
	new_board.name = %board_name.text
	$margain/interface_elements/tabs.add_child(new_board)
	boards.append({
		"name": new_board.name,
		"cards": []
	})
	
	%board_name.text = ""
	new_board.connect("card_created", card_created)
	new_board.connect("card_finished_status_changed", card_finished_changed)
	new_board.connect("card_deleted", card_deleted)
	new_board.connect("board_delete", board_delete)
	$margain/interface_elements/tabs.current_tab = $margain/interface_elements/tabs.get_children().size() -1
	board_file.set_value("board", "boards", boards)
	board_file.save("boards.brds")
	
func card_created(card_contents, card_priority, board_name):
	for board in boards:
		if board.name == board_name:
			board.cards.append({
				"contents": card_contents, 
				"finished": false, 
				"priority": card_priority
			})
	board_file.set_value("board", "boards", boards)
	board_file.save("boards.brds")

func card_finished_changed(finished_status : bool, card_name : String, board_name : String):
	for board in boards:
		if board.name == board_name:
			for card in board.cards:
				if card.contents == card_name:
					card.finished = finished_status
	board_file.set_value("board", "boards", boards)
	board_file.save("boards.brds")

func card_deleted(card_name : String, board_name : String):
	for board in boards:
		if board.name == board.name:
			for card in board.cards:
				if card.contents == card_name:
					board.cards.erase(card)
	board_file.set_value("board", "boards", boards)
	board_file.save("boards.brds")
	
func board_delete(board_name : String):
	for board in boards:
		if board.name == board_name:
			boards.erase(board)
	board_file.set_value("board", "boards", boards)
	board_file.save("boards.brds")
