extends Node2D

onready var parent : Minigame = get_parent()
var entered := false
var memory_counter := 0

func _ready():
	yield(get_tree().create_timer(1),'timeout')
	$Area.connect('body_entered', self, 'chunk_entered')
	parent.connect('updated_chunks', self ,'on_chunk_updates')

func chunk_entered(body):
	if entered == false:
		entered = true
		get_parent().update_chunk(position, self)

func on_chunk_updates():
	memory_counter += 1
	if memory_counter > 1:
		queue_free()