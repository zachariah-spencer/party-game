extends Node2D

var entered : bool = false

func _ready():
	yield(get_tree().create_timer(1),'timeout')
	$Area.connect('body_entered', self, 'chunk_entered')

func chunk_entered(body):
	if entered == false:
		entered = true
		get_parent().update_chunk(position)