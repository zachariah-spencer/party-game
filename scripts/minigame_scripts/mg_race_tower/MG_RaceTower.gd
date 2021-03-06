extends Minigame

#When a new map chunk scene to be randomly generated is created, adding it to this list
#should insert it into the procedural rotation
const CHUNKS  = [
	preload('res://scenes/minigames/mg_race_tower/maps/any_racetowermap1/chunks/TowerChunkTwo.tscn'),
	preload('res://scenes/minigames/mg_race_tower/maps/any_racetowermap1/chunks/TowerChunkThree.tscn'),
	preload('res://scenes/minigames/mg_race_tower/maps/any_racetowermap1/chunks/TowerChunkFour.tscn'),
	preload('res://scenes/minigames/mg_race_tower/maps/any_racetowermap1/chunks/TowerChunkFive.tscn'),
	preload('res://scenes/minigames/mg_race_tower/maps/any_racetowermap1/chunks/TowerChunkSix.tscn'),
	preload('res://scenes/minigames/mg_race_tower/maps/any_racetowermap1/chunks/TowerChunkSeven.tscn'),
	preload('res://scenes/minigames/mg_race_tower/maps/any_racetowermap1/chunks/TowerChunkEight.tscn'),
	preload('res://scenes/minigames/mg_race_tower/maps/any_racetowermap1/chunks/TowerChunkNine.tscn'),
]

var update_timer : int
export var lava_speed := 0.3
export var max_lava_speed := 3.0
export var lava_speed_increment := 0.05
export var lava_speed_incrementing_time := 1

signal updated_chunks

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'race_tower'
	game_instructions = "Race to\nEscape the Lava!"
	update_timer = game_time - lava_speed_incrementing_time
	$Lava.connect('body_entered',self,'_on_Lava_body_entered')

func _physics_process(delta):
	_handle_lava_speed()
	_run_minigame_loop()


func _run_minigame_loop():
	if game_active:
#		potential trig. implementation (needs difficulty tweaking)
#		$Lava.position.y -= lava_speed*(sin(game_time) + lava_speed * .1)

		$Lava.position.y -= lava_speed
		_check_game_win_conditions()

func _on_Lava_body_entered(player):
	player.hit(self, 100, Vector2.ZERO, Damage.FIRE)

func update_chunk(old_chunk : Node2D):
	#let all active chunks know that more are being loaded
	emit_signal('updated_chunks')
	CHUNKS.shuffle()
	var new_chunk = CHUNKS[0].instance()

	while new_chunk.chunk_id == old_chunk.chunk_id:
		CHUNKS.shuffle()
		new_chunk = CHUNKS[0].instance()

	#instance and set new chunk above players on the top of the tower
	new_chunk.position = old_chunk.position
	new_chunk.position.y -= old_chunk.size

	#add to tree
	call_deferred('add_child', new_chunk)

func _handle_lava_speed():
	if update_timer == game_time && lava_speed < (max_lava_speed-0.1):
		update_timer = game_time - lava_speed_incrementing_time
		lava_speed += lava_speed_increment