extends Node2D

onready var fall_timer = Timer.new()
export var fall_delay := 1.0
export var platform_size := 3
var blocks = []
var falling = false
var can_fall = true

func _ready():
	fall_timer.one_shot = true
	fall_timer.autostart = false
	fall_timer.connect("timeout", self, "end_fall")
	add_child(fall_timer)

	for plats in range(1,platform_size) :
		var add = $Terrain.duplicate()
		add.position.x = 64 * plats
		add_child(add)

	for child in get_children() :
		if child is RigidBody2D :
			blocks.append(child)

func fall(delay := fall_delay):
	if not falling :
		fall_timer.start(delay)
		$RumbleSFX.play()
		falling = true

func _process(delta):
	if can_fall and falling :
		for block in blocks :
			block.position.y += rand_range(-5, 5)
			block.position.y = clamp(block.position.y, -10, 10)

func end_fall() :
	$RumbleSFX.stop()
	can_fall = false
	for block in blocks :
		block.mode = RigidBody2D.MODE_RIGID
		block = block as RigidBody2D
		var offset = Vector2(rand_range(-32, 32), rand_range(-32, 32))
		block.apply_impulse(offset, Vector2.DOWN)