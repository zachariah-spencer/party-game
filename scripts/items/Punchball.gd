extends Item

onready var punch_area := $PunchArea
onready var impulse_timer := $ImpulseTimer
var random_impulse_speed := 20 * Globals.CELL_SIZE

func _ready():
	punch_area.collision_mask = 0
	_weight = 10

func _on_ImpulseTimer_timeout():
	var offset_vector : Vector2
	var impulse_vector : Vector2
	offset_vector.x = rand_range(-random_impulse_speed,random_impulse_speed)
	offset_vector.y = rand_range(-random_impulse_speed,random_impulse_speed)
	impulse_vector.x = rand_range(-random_impulse_speed,random_impulse_speed)
	impulse_vector.y = rand_range(-random_impulse_speed,random_impulse_speed)
	
	apply_impulse(offset_vector, impulse_vector)