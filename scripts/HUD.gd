extends Control

#tells GameStateManager singleton when to transition to a new minigame
#DELETE: signal game_times_up

#reference to time counter display
onready var time_display : Label = $TimeLeft

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

func _check_game_over():
	#only overwrite the instructions box with the game instructions if the game is active,
	#once the games win conditions are reached, stop updating the instructions to allow,
	#that label to be reused as a way to tell the players who won.
	if get_parent().get_parent().game_over:
		#do this stuff if the current games win conditions HAVE been reached
		if Manager.current_game_time != 0:
			#in the event of a game win
			time_display.text = String(Manager.current_game_time+1)
		elif Manager.current_game_time == 0:
			#in the event of a game timing out
			time_display.text = '0'
	else:
		#do this stuff if the current games win conditions HAVE NOT been reached
		time_display.text = String(Manager.current_game_time)
		$TimeLeft/Instructions.text = Manager.current_game_reference.game_instructions


func _update_game_timer():
	#set the timer ui to the current game time
	if !Manager.current_game_reference.has_timer:
		#if the current minigame DOES NOT display a timer
		#then overwrite the timer space with a blank string
		$TimeLeft.text = ''
	elif Manager.current_game_reference.has_timer:
		#if the current minigame DOES display a timer
		#then set the timers text to the current game time as a String
		$TimeLeft.text = String(Manager.current_game_time)

func _update_hud():
	#DEV NOTE: still needs work so that when players return to the lobby their statuses re-appear
	#buffer for a split second to allow other variables to update before the call to update hud
	#^^^this yield is more of a safeguard against pre-emptive memory grabassing
	yield(get_tree().create_timer(.01),'timeout')
	#call all the previously notated functions
	_check_game_over()
	_update_active_players()
	_update_scores()
	_update_game_timer()

func _on_Timer_timeout():
	#function that is tied to a one second looping 'timeout' signal.
	#this checks if the current game has a timer, if it does it handles the time every second
	#else it overwrites the timer UI with a blank String
	if Manager.current_game_reference.has_timer:
		_check_game_over()
		_update_game_timer()
	else:
		$TimeLeft.text = ''

func _every_second():
	print('in every second')
	#this is what keeps track of the minigame time
	if Manager.current_game_reference.game_active:
		#if game is active then count time down
		if Manager.current_game_time != 0:
			Manager.current_game_time -= 1
			time_display.text = String(Manager.current_game_time)
		elif Manager.current_game_time == 0:
			#the 3 second buffer state between one minigame ending 
			#and the transition to the next one if the game times out to 0
			time_display.text = '0'
			yield(get_tree().create_timer(3), 'timeout')
			emit_signal('game_times_up')
	else:
		#the 3 second buffer state between one minigame ending 
		#and the transition to the next one if the game is won
		yield(get_tree().create_timer(3), 'timeout')
		emit_signal('game_times_up')