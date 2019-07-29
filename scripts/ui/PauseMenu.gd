extends Control

var pause_state := false
var can_pause := true
onready var main := $MainPause
onready var settings := $Settings

func _ready():
	Globals.pause_menu = self

func _input(event):
	if pause_state:
		if event.is_action_pressed('player_one_start'):
			toggle_pause_game()
			can_pause = false
			$CanPauseTimer.start()

func toggle_pause_game(player = null):
	if can_pause:
		pause_state = not get_tree().paused
		get_tree().paused = pause_state
		visible = pause_state
	
	if pause_state:
		settings.visible = false
		main.visible = true

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


func _on_CheckBox_pressed():
	var new_state = not OS.window_fullscreen
	OS.window_fullscreen = new_state


func _on_CanPauseTimer_timeout():
	can_pause = true
