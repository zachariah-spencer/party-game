extends Lever

var infinite_state := false

onready var infinite_label := $'../InfiniteLabel'
onready var rounds_label := $'../RoundsLabel'
onready var desc_label := $'../DescLabel'

func _ready():
	infinite_label.text = 'Infinite: ' + _get_infinite_state()
	Manager.repeats = false

func flip():
	.flip()
	infinite_state = !infinite_state
	Manager.repeats = infinite_state
	infinite_label.text = String('Infinite: ' + _get_infinite_state())
	rounds_label.visible = false if infinite_state else true

	if !infinite_state:
		parent.num_rounds = 10
		rounds_label.text = String(parent.num_rounds)

func _get_infinite_state():
	return 'on' if infinite_state else 'off'

