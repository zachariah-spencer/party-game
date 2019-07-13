extends Minigame

var has_spawned_nade := false
var starting_horseshoes := false

var first_area_player = null
var second_area_player = null
var third_area_player = null
var fourth_area_player = null

onready var first_area := map.get_node('PositionHandlers/FirstArea')
onready var second_area := map.get_node('PositionHandlers/SecondArea')
onready var third_area := map.get_node('PositionHandlers/ThirdArea')
onready var fourth_area := map.get_node('PositionHandlers/FourthArea')

onready var first_grenade_spawn := map.get_node('PositionHandlers/FirstGrenadeSpawn')
onready var second_grenade_spawn := map.get_node('PositionHandlers/SecondGrenadeSpawn')
onready var third_grenade_spawn := map.get_node('PositionHandlers/ThirdGrenadeSpawn')
onready var fourth_grenade_spawn := map.get_node('PositionHandlers/FourthGrenadeSpawn')

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

#		if !has_spawned_nade:
#			Players.player_one.child.set_item(grenade.instance())
#			has_spawned_nade = true

func _on_begin_game():
	._on_begin_game()
	for player in Players._get_alive_players():
		#distribute the initial horseshoes here
		pass