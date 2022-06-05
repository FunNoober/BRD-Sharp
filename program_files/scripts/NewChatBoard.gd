extends Tabs

onready var alias_field = get_node("Contents/HSplitContainer/MessageArea/HBoxContainer/AliasEdit")
onready var contents_field = get_node("Contents/HSplitContainer/MessageArea/HBoxContainer/MessageContentsEdit")

var messages = []

func _ready() -> void:
	var f = File.new()
	if f.file_exists("user://" + name + ".brdchat"):
		f.open("user://" + name + ".brdchat", f.READ)
		messages = parse_json(f.get_as_text()).messages
		for i in range(len(messages)):
			$Contents/HSplitContainer/MessageArea/MessagesLabel.text += messages[i]
		f.close()

remote func send_chat_message(alias, message):
	$Contents/HSplitContainer/MessageArea/MessagesLabel.text += alias + " : " + message + "\n"
	messages.append(alias + " : " + message + "\n")
	save()
 
func _on_SendButton_pressed() -> void:
	send_chat_message(alias_field.text, contents_field.text)
	rpc("send_chat_message", alias_field.text, contents_field.text)
	contents_field.text = ""

func _on_MessageContentsEdit_text_entered(_new_text: String) -> void:
	send_chat_message(alias_field.text, contents_field.text)
	rpc("send_chat_message", alias_field.text, contents_field.text)
	contents_field.text = ""

func save():
	var data_to_store = {
		"messages" : messages
	}
	var f = File.new()
	f.open("user://" + name + ".brdchat", f.WRITE)
	f.store_string(JSON.print(data_to_store))
	f.close()
