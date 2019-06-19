extends Area2D

var owned_by : PlayersManager
var player_on_flag : Player

signal flag_captured
signal flag_deowned

func _ready():
	connect('flag_captured', get_parent(),'_increase_local_score')
	connect('flag_deowned', get_parent(),'_decrease_local_score')

func hit(by : Node, damage : int, knockback : Vector2):
	print('here')
	if player_on_flag:
		print('in if here')
		owned_by = by.parent
		modulate = owned_by.modulate
		emit_signal('flag_captured', owned_by, 1)

func _on_Flag_body_entered(body):
	player_on_flag = body as Player


func _on_Flag_body_exited(body):
	player_on_flag = null
