extends Area2D

var owned_by : PlayersManager = null
var player_on_flag : Player = null
export var start_owner := 0

signal flag_captured
signal flag_deowned

func _ready():
	match start_owner:
		1:
			owned_by = Players.player_one
		2:
			owned_by = Players.player_two
		3:
			owned_by = Players.player_three
		4:
			owned_by = Players.player_four
	
	
	connect('flag_captured', Manager.current_minigame,'_increase_local_score')
	connect('flag_deowned', Manager.current_minigame,'_decrease_local_score')
	connect('body_entered', self, '_on_InteractArea_body_entered')
	connect('body_exited', self, '_on_InteractArea_body_exited')
	
	if owned_by:
		modulate = owned_by.modulate
		emit_signal('flag_captured', owned_by, 1)

func interact(by : Player):
	if !Manager.current_minigame.game_over:
		yield(get_tree(), "idle_frame")
		for body in get_overlapping_bodies() :
			if body == by:
				_flag_flip(by.parent)

func _on_InteractArea_body_entered(body):
	player_on_flag = body as Player


func _on_InteractArea_body_exited(body):
	player_on_flag = null

func _flag_flip(by : PlayersManager):
	if by != owned_by:
		if owned_by:
			emit_signal('flag_deowned', owned_by, 1)
		
		if !owned_by:
			Manager.current_minigame.total_owned_flags += 1
		
		owned_by = by
		modulate = owned_by.modulate
		emit_signal('flag_captured', owned_by, 1)
