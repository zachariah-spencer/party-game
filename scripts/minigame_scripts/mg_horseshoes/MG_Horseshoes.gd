extends Minigame

onready var grenade = load('res://scenes/items/Grenade.tscn')

func _init():
	maps = [
	preload('res://scenes/minigames/mg_horseshoes/maps/Any_HorseshoesMap1.tscn'),
	]


func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'horseshoes'
	game_instructions = 'Land a horseshoe to help \n kill the others!'

func on_made_shot(player):
	for p in Players.active_players :
		if p != player.parent :
			var rand = Vector2(rand_range(-100, 100), rand_range(-100, 100))
			_spawn_grenade(p.position + rand)

func _spawn_grenade(spawn_pos):
	var grenade_instance = grenade.instance()
	grenade_instance.position = spawn_pos
	grenade_instance.prelit = true
	call_deferred('add_child', grenade_instance)

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():

	if game_active:
		_check_game_win_conditions()

func _on_begin_game():
	._on_begin_game()
	for player in Players._get_alive_players():
		#distribute the initial horseshoes here
		pass