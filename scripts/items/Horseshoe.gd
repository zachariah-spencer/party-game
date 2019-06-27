extends Item

func _ready():
	connect("thrown", self, "_on_throw")
	_weight = 4

