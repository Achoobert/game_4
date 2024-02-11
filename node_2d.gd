extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var contacts_list = $Control/ItemList
	contacts_list.add_item('Bob Stone')
	contacts_list.add_item('Alice Vunderlund')
	contacts_list.add_item('Nancy Drew')
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	

func _input(event: InputEvent):
	# check if a dialog is already running
	if Dialogic.current_timeline != null:
		print("no timeline")
		return

	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		print("timeline trigger")
		#Dialogic.start('story1')
		#print("got timeline")
		get_viewport().set_input_as_handled()


func _on_item_list_item_selected(index):
	print("this was selected", index)
	# we start a conversation with the selected contact
	_on_contact_selected(index)
	pass # Replace with function body.

func _on_contact_selected(index):
	match index:
		0:
			print("this is the default list item")
			Dialogic.start('defaulttimeline')
			pass
		1:
			Dialogic.start('convince_Bob')
		2:
			Dialogic.start('convince_Alice')
		3:
			# res://dialogic/Timelines/convince_Nancy.dtl
			Dialogic.start('dialogic/Timelines/convince_Nancy')
			#Dialogic.start('convince_Nancy')

func _on_item_list_ready():
	pass # Replace with function body.
