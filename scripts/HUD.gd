extends Control

signal game_times_up

onready var time_display = $TimeLeft

func _ready():
	Globals.HUD = self

	#warning-ignore:return_value_discarded
	connect('game_times_up', Manager, '_on_game_times_up')

	call_deferred('_update_hud')

func _validate_active_players():
	if is_instance_valid(Globals.player_one):
		$Scorecards/P1Score.visible = true
		$Scorecards/P1Ready.visible = true
		$Scorecards/P1Score.text = String(Globals.player_one.score)
		
	if is_instance_valid(Globals.player_two):
		$Scorecards/P2Score.visible = true
		$Scorecards/P2Ready.visible = true
		$Scorecards/P2Score.text = String(Globals.player_two.score)
	if is_instance_valid(Globals.player_three):
		$Scorecards/P3Score.visible = true
		$Scorecards/P3Ready.visible = true
		$Scorecards/P3Score.text = String(Globals.player_three.score)
	if is_instance_valid(Globals.player_four):
		$Scorecards/P4Score.visible = true
		$Scorecards/P4Ready.visible = true
		$Scorecards/P4Score.text = String(Globals.player_four.score)

func _update_hud():
	yield(get_tree().create_timer(.1),'timeout')

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