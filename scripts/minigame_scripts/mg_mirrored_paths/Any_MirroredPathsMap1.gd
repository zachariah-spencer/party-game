extends Map

var top_empty := false
var bottom_empty := false

const CHUNKS  = [
	preload('res://scenes/minigames/mg_mirrored_paths/maps/any_mirroredpathsmap1/chunks/PathChunkOne.tscn'),
	preload('res://scenes/minigames/mg_mirrored_paths/maps/any_mirroredpathsmap1/chunks/PathChunkTwo.tscn'),
	#pathchunkthree is the starting chunk
	preload('res://scenes/minigames/mg_mirrored_paths/maps/any_mirroredpathsmap1/chunks/PathChunkFour.tscn'),
	preload('res://scenes/minigames/mg_mirrored_paths/maps/any_mirroredpathsmap1/chunks/PathChunkFive.tscn'),
	preload('res://scenes/minigames/mg_mirrored_paths/maps/any_mirroredpathsmap1/chunks/PathChunkSix.tscn'),
	preload('res://scenes/minigames/mg_mirrored_paths/maps/any_mirroredpathsmap1/chunks/PathChunkSeven.tscn'),
	preload('res://scenes/minigames/mg_mirrored_paths/maps/any_mirroredpathsmap1/chunks/PathChunkEight.tscn'),
]

func update_chunk(old_chunk : Node2D):
	#let all active chunks know that more are being loaded
	CHUNKS.shuffle()
	var new_chunk = CHUNKS[0].instance()
	
	if !top_empty && !bottom_empty:
		while new_chunk.chunk_id == old_chunk.chunk_id || new_chunk.path != new_chunk.paths.both:
			CHUNKS.shuffle()
			new_chunk = CHUNKS[0].instance()
	else:
		if top_empty:
			while new_chunk.chunk_id == old_chunk.chunk_id || new_chunk.path != new_chunk.paths.bottom:
				CHUNKS.shuffle()
				new_chunk = CHUNKS[0].instance()
		elif bottom_empty:
			while new_chunk.chunk_id == old_chunk.chunk_id || new_chunk.path != new_chunk.paths.top:
				CHUNKS.shuffle()
				new_chunk = CHUNKS[0].instance()

	#instance and set new chunk above players on the top of the tower
	new_chunk.position = old_chunk.position
	new_chunk.position.x += old_chunk.size

	#add to tree
	call_deferred('add_child', new_chunk)
