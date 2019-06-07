extends Control

signal game_times_up

onready var time_display = $TimeLeft

func _ready():
	Globals.current_HUD = self

	#warning-ignore:return_value_discarded
	connect('game_times_up', Manager, '_on_game_times_up')

	call_deferred('_update_hud')

func _update_hud():
	yield(get_tree().create_timer(.1),'timeout')
	$TimeLeft/Instructions.text = Manager.current_game_reference.game_instructions
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