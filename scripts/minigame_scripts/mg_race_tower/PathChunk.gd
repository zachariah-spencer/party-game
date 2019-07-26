extends Node2D
class_name PathChunk

onready var parent : Minigame = get_parent()
enum paths {top, bottom, both}
var entered := false
var memory_counter := 0
export var size := 1280
export var chunk_id := 3
export(paths) var path := paths.both

func _ready():
	$Area.connect('body_entered', self, 'chunk_entered')

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
