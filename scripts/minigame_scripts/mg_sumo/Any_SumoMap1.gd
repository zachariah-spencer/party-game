extends Map

var platform = []
var FallingBlocks = preload("res://scenes/map_elements/FallingBlocks.tscn")
export var min_platform_size := 3
export var max_platform_size := 6
export var stage_size := 6
export var drop_delay := 3.0
var drop_timer = Timer.new()


func _ready():
	drop_timer.autostart = false
	drop_timer.connect("timeout", self, "drop")
	add_child(drop_timer)
	_gen_stage()

func start_game():
	drop_timer.start(drop_delay)

func drop():
	if platform.size() == 1 : return
	if randi() % 2 == 0 :
		platform.pop_back().fall()
	else :
		platform.pop_front().fall()


func _gen_stage(size := stage_size) :
	var curr = Vector2.ZERO
	for plat in stage_size :
		var plat_size = rand_range(min_platform_size, max_platform_size)
		var new_plat = FallingBlocks.instance()
		new_plat.platform_size = int(plat_size)
		new_plat.position = curr
		curr.x += int(plat_size) * 64
		platform.append(new_plat)
		add_child(new_plat)