extends Item

func _ready():
	connect("thrown", self, "_on_throw")
	_weight = 4

func _on_throw():
	pass

func _hurtbox_entered(body):
	var player = body as Player
	var item = body as Item
	if player :
		player.hit_points = 0
	elif body != self :
		_deown()