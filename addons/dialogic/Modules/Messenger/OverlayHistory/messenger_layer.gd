@tool
extends DialogicLayoutLayer

## Example scene for viewing a message style version of a dialogue
## Implements some visual options from 1.x History mode

@export_group('Look')
@export_subgroup('Font')
@export var font_use_global_size: bool = true
@export var font_custom_size: int = 15
@export var font_use_global_fonts: bool = true
@export_file('*.ttf') var font_custom_normal: String = ""
@export_file('*.ttf') var font_custom_bold: String = ""
@export_file('*.ttf') var font_custom_italics: String = ""

@export_subgroup('Buttons')
@export var show_open_button: bool = true
@export var show_close_button: bool = true

@export_group('Settings')
@export_subgroup('Events')
@export var show_all_choices: bool = true
@export var show_join_and_leave: bool = true

@export_subgroup('Behaviour')
@export var scroll_to_bottom: bool = true
@export var show_name_colors: bool = true
@export var name_delimeter: String = ": "

var scroll_to_bottom_flag: bool = false

@export_group('Private')
@export var MessageItem: PackedScene = null
@export var HistoryItem: PackedScene = null

var message_item_theme: Theme = null

func get_show_history_button() -> Button:
	return $ShowMessages
	
func show_messages_button() -> Button:
	return $ShowMessages


func get_hide_history_button() -> Button:
	return $HideMessages


func get_history_box() -> ScrollContainer:
	return %MessageBox


func get_history_log() -> VBoxContainer:
	return %MessageLog


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	Dialogic.History.open_requested.connect(_on_show_history_pressed)
	#Dialogic.History.close_requested.connect(_on_hide_history_pressed)


func _apply_export_overrides() -> void:
	var history_subsystem: Node = DialogicUtil.autoload().get(&'History')
	#if history_subsystem != null:
		#get_show_history_button().visible = show_open_button and history_subsystem.get(&'simple_history_enabled')
	#else:
	#show_messages_button().visible
	#set(&'visible', true)

	message_item_theme = Theme.new()

	if font_use_global_size:
		message_item_theme.default_font_size = get_global_setting(&'font_size', font_custom_size)
	else:
		message_item_theme.default_font_size = font_custom_size

	if font_use_global_fonts and ResourceLoader.exists(get_global_setting(&'font', '') as String):
		message_item_theme.default_font = load(get_global_setting(&'font', '') as String) as Font
	elif ResourceLoader.exists(font_custom_normal):
		message_item_theme.default_font = load(font_custom_normal)

	if ResourceLoader.exists(font_custom_bold):
		message_item_theme.set_font(&'RichtTextLabel', &'bold_font', load(font_custom_bold) as Font)
	if ResourceLoader.exists(font_custom_italics):
		message_item_theme.set_font(&'RichtTextLabel', &'italics_font', load(font_custom_italics) as Font)



# TODO @achoobert
func _process(_delta : float) -> void:
	show_history()
	if Engine.is_editor_hint():
		return
	if scroll_to_bottom_flag and get_history_box().visible and get_history_log().get_child_count():
		await get_tree().process_frame
		get_history_box().ensure_control_visible(get_history_log().get_children()[-1] as Control)
		scroll_to_bottom_flag = false


func _on_show_history_pressed() -> void:
	# TODO what is this actually trying to do>
	#DialogicUtil.autoload().paused = true
	show_history()

# @achoobert
func show_history() -> void:
	for child: Node in get_history_log().get_children():
		child.queue_free()

	var history_subsystem: Node = DialogicUtil.autoload().get(&'History')
	for info: Dictionary in history_subsystem.call(&'get_simple_history'):
		var h_item : Node = HistoryItem.instantiate()
		var message_item : Node = MessageItem.instantiate()
		message_item.set(&'theme', message_item_theme)
		# TODO @achoobert this is where we add the pfp
		match info.event_type:
			"Text":
				if info.has('character') and info['character']:
					if show_name_colors:
						message_item.call(&'load_info', info['text'], info['character']+name_delimeter, info['character_color'])
					else:
						message_item.call(&'load_info', info['text'], info['character']+name_delimeter)
				else:
					message_item.call(&'load_info', info['text'])
			"Character":
				if !show_join_and_leave:
					message_item.queue_free()
					continue
				message_item.call(&'load_info', '[i]'+info['text'])
			"Choice":
				var choices_text: String = ""
				if show_all_choices:
					for i : String in info['all_choices']:
						if i.ends_with('#disabled'):
							choices_text += "-  [i]("+i.trim_suffix('#disabled')+")[/i]\n"
						elif i == info['text']:
							choices_text += "-> [b]"+i+"[/b]\n"
						else:
							choices_text += "-> "+i+"\n"
				else:
					choices_text += "- [b]"+info['text']+"[/b]\n"
				message_item.call(&'load_info', choices_text)

		# TODO @achoobert
		get_history_log().add_child(message_item)

	if scroll_to_bottom:
		scroll_to_bottom_flag = true

	#get_show_history_button().hide()
	#get_hide_history_button().visible = show_close_button
	get_history_box().show()


#func _on_hide_history_pressed() -> void:
	#DialogicUtil.autoload().paused = false
	#get_history_box().hide()
	#get_hide_history_button().hide()
	#var history_subsystem: Node = DialogicUtil.autoload().get(&'History')
	#get_show_history_button().visible = show_open_button and history_subsystem.get(&'simple_history_enabled')
