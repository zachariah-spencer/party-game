extends Grenade

func _ready():
	$DetonationArea.connect("body_entered", self, "_det_body_entered")

func _det_body_entered(body):
	if body is Player :
		if body != _owner :
			_fuse_timeout()

func _on_grab():
	$DetonationArea.collision_mask = 0

func _on_throw() :
	$DetonationArea.collision_mask = get_hit_mask(hit_types.everybody)
	._on_throw()