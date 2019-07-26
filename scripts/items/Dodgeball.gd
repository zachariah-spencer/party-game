extends Item

func _ready():
	$Hurtbox.connect("body_entered", self, "_hurtbox_entered")
	connect("thrown", self, "_on_throw")
	$Hurtbox.collision_mask = 0
	_weight = 4

func _on_throw():
	$Hurtbox.collision_mask = get_hit_mask(hit_types.opponents) + get_hit_mask(hit_types.terrain_no_platforms)

func _hurtbox_entered(body):
	var player = body as Player
	var item = body as Item
	if player :
		player.hit_points = 0
	elif body != self :
		_deown()

func _deown():
	$Hurtbox.collision_mask = 0
	._deown()