extends Area2D

var spawn_points : Array

func _ready():
	connect("body_entered",self,'on_body_entered')
	
	spawn_points = get_parent().get_node('SpawnPoints').get_children()
	spawn_points.shuffle()

func on_body_entered(body):
	var player = body as Player
	
	if player:
		#having performance issues with this code
		player.parent.spawn(spawn_points[0].position)
		spawn_points.shuffle()