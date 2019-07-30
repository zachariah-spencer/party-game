extends Control

var pause_state := false
onready var main := $MainPause
onready var settings := $Settings

func _ready():
	Globals.pause_menu = self

func _input(event):
	if pause_state:
		if event.is_action_pressed('ui_cancel'):
			if main.visible:
				toggle_pause_game()
			elif settings.visible:
				main.get_node('SettingsButton').grab_focus()
				settings.visible = false
				main.visible = true

func toggle_pause_game(player = null):
	if pause_state:
		pause_state = not get_tree().paused
		get_tree().paused = pause_state
		visible = pause_state
		_deregister_controls()
	else:
		pause_state = not get_tree().paused
		get_tree().paused = pause_state
		visible = pause_state
		_register_controls(int(player.player_number))
		main.get_node('Resume').grab_focus()
	
	if pause_state:
		settings.visible = false
		main.visible = true


func _register_controls(_device : int):
	_device -= 1
	
	var axis_ev := InputEventJoypadMotion.new()
	axis_ev.set_axis(JOY_AXIS_1)
	axis_ev.set_axis_value(1.0)
	axis_ev.device = _device
	InputMap.action_add_event('ui_down', axis_ev)
	
	axis_ev = InputEventJoypadMotion.new()
	axis_ev.set_axis(JOY_AXIS_1)
	axis_ev.set_axis_value(-1.0)
	axis_ev.device = _device
	InputMap.action_add_event('ui_up', axis_ev)
	
	var button_ev := InputEventJoypadButton.new()
	button_ev.set_button_index(JOY_BUTTON_0)
	button_ev.device = _device
	InputMap.action_add_event('ui_accept', button_ev)
	
	button_ev = InputEventJoypadButton.new()
	button_ev.set_button_index(JOY_BUTTON_1)
	button_ev.device = _device
	InputMap.action_add_event('ui_cancel', button_ev)


func _deregister_controls():
	InputMap.action_erase_events('ui_up')
	InputMap.action_erase_events('ui_down')
	InputMap.action_erase_events('ui_accept')
	InputMap.action_erase_events('ui_cancel')


func _on_Return_To_Lobby_pressed():
	if pause_state:
		get_tree().paused = !pause_state
		visible = false
		Players.reset_players_data()
		Manager._start_new_minigame(Manager.lobby)


func _on_SettingsButton_pressed():
	if pause_state:
		main.visible = false
		settings.visible = true
		settings.get_node('FullscreenCheckbox').grab_focus()


func _on_QuitGameButton_pressed():
	if pause_state:
		get_tree().quit()


func _on_MuteSoundsButton_pressed():
	if pause_state:
		print('muted sounds')


func _on_MuteMusicButton_pressed():
	if pause_state:
		print('muted music')


func _on_BackButton_pressed():
	if pause_state:
		settings.visible = false
		main.visible = true
		main.get_node('Resume').grab_focus()


func _on_CheckBox_pressed():
	var new_state = not OS.window_fullscreen
	OS.window_fullscreen = new_state


func _on_Resume_pressed():
	if pause_state:
		toggle_pause_game()
