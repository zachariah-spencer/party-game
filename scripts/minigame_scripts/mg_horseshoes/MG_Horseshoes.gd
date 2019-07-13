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
	
	
	first_area.connect('body_entered', Manager.current_minigame, 'register_first_area')
	second_area.connect('body_entered', Manager.current_minigame, 'register_second_area')
	third_area.connect('body_entered', Manager.current_minigame, 'register_third_area')
	fourth_area.connect('body_entered', Manager.current_minigame, 'register_fourth_area')

func register_first_area(body):
	var player = body as Player
	if player:
		first_area_player = player.parent

func register_second_area(body):
	var player = body as Player
	if player:
		second_area_player = player.parent

func register_third_area(body):
	var player = body as Player
	if player:
		third_area_player = player.parent

func register_fourth_area(body):
	var player = body as Player
	if player:
		fourth_area_player = player.parent

func on_made_shot(player):
	player = player.parent
	var landed_player = null
	
	match player:
		first_area_player:
			landed_player = first_area_player
		second_area_player:
			landed_player = second_area_player
		third_area_player:
			landed_player = third_area_player
		fourth_area_player:
			landed_player = fourth_area_player
	
	if landed_player != first_area_player:
		_spawn_grenade(first_grenade_spawn.position)
	if landed_player != second_area_player:
		_spawn_grenade(second_grenade_spawn.position)
	if landed_player != third_area_player:
		_spawn_grenade(third_grenade_spawn.position)
	if landed_player != fourth_area_player:
		_spawn_grenade(fourth_grenade_spawn.position)

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