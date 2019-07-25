extends Map


const CHUNKS  = [
	preload('res://scenes/minigames/mg_mirrored_paths/maps/any_mirroredpathsmap1/chunks/PathChunkOne.tscn'),
	preload('res://scenes/minigames/mg_mirrored_paths/maps/any_mirroredpathsmap1/chunks/PathChunkTwo.tscn'),
	#pathchunkthree is the starting chunk
	preload('res://scenes/minigames/mg_mirrored_paths/maps/any_mirroredpathsmap1/chunks/PathChunkFour.tscn')
]

func update_chunk(old_chunk : Node2D):
	#let all active chunks know that more are being loaded
	CHUNKS.shuffle()
	var new_chunk = CHUNKS[0].instance()

	while new_chunk.chunk_id == old_chunk.chunk_id:
		CHUNKS.shuffle()
		new_chunk = CHUNKS[0].instance()

	#instance and set new chunk above players on the top of the tower
	new_chunk.position = old_chunk.position
	new_chunk.position.x += old_chunk.size

	#add to tree
	call_deferred('add_child', new_chunk)
