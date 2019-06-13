extends Item

func _ready():
	$Hurtbox.connect("body_entered", self, "_hurtbox_entered")
	connect("thrown", self, "_on_throw")
	$Hurtbox.collision_mask = 0

func _on_throw():
	$Hurtbox.collision_mask = _owner.collision_mask
	$Hurtbox.set_collision_mask_bit(3, false)
	$Hurtbox.set_collision_mask_bit(0, true)
	$Hurtbox.set_collision_mask_bit(4, true)



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