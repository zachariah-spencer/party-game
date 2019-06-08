extends Control

signal game_times_up

onready var time_display = $TimeLeft

func _ready():
	Globals.HUD = self

	#warning-ignore:return_value_discarded
	connect('game_times_up', Manager, '_on_game_times_up')

	call_deferred('_update_hud')

func _validate_active_players():
	if Players.player_one.active:
		$Scorecards/P1Score.visible = true
		$Scorecards/Statuses/P1Ready.visible = true
		$Scorecards/P1Score.text = String(Players.player_one.score)
	if Players.player_two.active:
		$Scorecards/P2Score.visible = true
		$Scorecards/Statuses/P2Ready.visible = true
		$Scorecards/P2Score.text = String(Players.player_two.score)
	if Players.player_three.active:
		$Scorecards/P3Score.visible = true
		$Scorecards/Statuses/P3Ready.visible = true
		$Scorecards/P3Score.text = String(Players.player_three.score)
	if Players.player_four.active:
		$Scorecards/P4Score.visible = true
		$Scorecards/Statuses/P4Ready.visible = true
		$Scorecards/P4Score.text = String(Players.player_four.score)


	if Manager.current_game_name != 'lobby':
		for status in $Scorecards/Statuses.get_children():
			status.visible = false

func _update_hud():
	yield(get_tree().create_timer(.1),'timeout')

	#still needs work so that when players return to the lobby their statuses re-appear


	if !get_parent().get_parent().game_over:
		$TimeLeft/Instructions.text = Manager.current_game_reference.game_instructions

	_validate_active_players()

	if !Manager.current_game_reference.has_timer:
		$TimeLeft.text = ''
	elif Manager.current_game_reference.has_timer:
		$TimeLeft.text = String(Manager.current_game_time)

func _physics_process(delta):
	pass
	#set so that the hud centers on the Y position of the camera's center

func _on_Timer_timeout():
	if Manager.current_game_reference.has_timer:
		_every_second()
	else:
		$TimeLeft.text = ''

func _every_second():
	if Manager.current_game_reference.game_active:
		if Manager.current_game_time != 0:
			Manager.current_game_time -= 1
			time_display.text = String(Manager.current_game_time)
		elif Manager.current_game_time == 0:
			emit_signal('game_times_up')
	else:
		time_display.text = '0'
		yield(get_tree().create_timer(3), 'timeout')
		emit_signal('game_times_up')