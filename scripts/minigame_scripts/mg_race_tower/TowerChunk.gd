extends Node2D
class_name TowerChunk

onready var parent : Minigame = get_parent()
var entered := false
var memory_counter := 0
export var size := 4096

func _ready():
	$Area.connect('body_entered', self, 'chunk_entered')
	parent.connect('updated_chunks', self ,'on_chunk_updates')

func chunk_entered(body):
	if body.is_in_group("player") :
		if entered == false:
			entered = true
			get_parent().update_chunk(self)

func on_chunk_updates():
	pass
# I don't think we need to free past chunks
#	memory_counter += 1
#	if memory_counter > 1:
#		queue_free()
