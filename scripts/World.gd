extends Node

var current_game = 'lobby'
onready var current_game_node = $MG_Lobby

onready var p1 = $Players/PlayerOne
onready var p2 = $Players/PlayerTwo
onready var p3 = $Players/PlayerThree
onready var p4 = $Players/PlayerFour

onready var spawn_points = current_game_node.get_node('SpawnPoints').get_children()

func _ready():
	p1.position = spawn_points[0].position
	p2.position = spawn_points[1].position
	p3.position = spawn_points[2].position
	p4.position = spawn_points[3].position
	for i in spawn_points:
		print(i.name + ': ' + String(i.position))