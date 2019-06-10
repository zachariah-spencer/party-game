extends Control

#tells GameStateManager singleton when to transition to a new minigame
#DELETE: signal game_times_up

#reference to time counter display
onready var time_display : Label = $TimeLeft
onready var minigame : Node = get_parent().get_parent()
signal begin_game

func _ready():
	#register to singleton
	Globals.HUD = self
	
	#connect the game_times_up signal upon readying in the tree
	#warning-ignore:return_value_discarded
	#DELETE: connect('game_times_up', Manager, '_on_game_times_up')
	
	#update the hud with new information
	call_deferred('_update_hud')

func _update_active_players():
	#check which players are activated and make their hud elements visible,
	#else make them not visible
	if Players.player_one.active:
		$Scorecards/P1Score.visible = true
		$Scorecards/Statuses/P1Ready.visible = true
	else:
		$Scorecards/P1Score.visible = false
		$Scorecards/Statuses/P1Ready.visible = false
	
	if Players.player_two.active:
		$Scorecards/P2Score.visible = true
		$Scorecards/Statuses/P2Ready.visible = true
	else:
		$Scorecards/P2Score.visible = false
		$Scorecards/Statuses/P2Ready.visible = false
	
	if Players.player_three.active:
		$Scorecards/P3Score.visible = true
		$Scorecards/Statuses/P3Ready.visible = true
	else:
		$Scorecards/P3Score.visible = false
		$Scorecards/Statuses/P3Ready.visible = false
	
	if Players.player_four.active:
		$Scorecards/P4Score.visible = true
		$Scorecards/Statuses/P4Ready.visible = true
	else:
		$Scorecards/P4Score.visible = false
		$Scorecards/Statuses/P4Ready.visible = false
	
	#remove the 'Ready/Not Ready' system from the hud UI unless players are in the lobby
	if Manager.current_game_name != 'lobby':
		for status in $Scorecards/Statuses.get_children():
			status.visible = false

func _update_scores():
	#get current playerscores for each player and set the UI to reflect that
	if Players.player_one.active:
		$Scorecards/P1Score.text = String(Players.player_one.score)
	if Players.player_two.active:
		$Scorecards/P2Score.text = String(Players.player_two.score)
	if Players.player_three.active:
		$Scorecards/P3Score.text = String(Players.player_three.score)
	if Players.player_four.active:
		$Scorecards/P4Score.text = String(Players.player_four.score)


func _update_game_timer():
	if minigame.has_timer:
		if !minigame.game_over:
			#do this stuff if the current games win conditions HAVE NOT been reached
			$TimeLeft.text = String(Manager.current_game_time)
			$TimeLeft/Instructions.text = Manager.current_game_reference.game_instructions
		else:
			$TimeLeft.text = String(Manager.current_game_time)
	else:
		$TimeLeft.text = ''

func _update_hud():
	#DEV NOTE: still needs work so that when players return to the lobby their statuses re-appear
	#buffer for a split second to allow other variables to update before the call to update hud
	#^^^this yield is more of a safeguard against pre-emptive memory grabassing
	yield(get_tree().create_timer(.01),'timeout')
	#call all the previously notated functions
	_update_active_players()
	_update_scores()
	_update_game_timer()

func _process(delta):
	if Manager.current_game_reference.has_timer:
		if minigame.game_active:
			_update_game_timer()
		elif !minigame.game_active && !minigame.game_over && minigame.has_countdown:
			if $Countdown/CountdownTimer.is_stopped():
				$Countdown/CountdownTimer.start()
				$Countdown.visible = true
	else:
		$TimeLeft.text = ''

func _on_CountdownTimer_timeout():
	match $Countdown.text:
		'3':
			$Countdown.text = '2'
			$Countdown.modulate = Color(1,1,0,1)
		'2':
			$Countdown.text = '1'
			$Countdown.modulate = Color(0,1,0,1)
		'1':
			$Countdown.text = 'Begin!'
			$Countdown.modulate = Color(1,1,1,1)
			emit_signal('begin_game')
		'Begin!':
			$Countdown.visible = false
			$Countdown/CountdownTimer.stop()
