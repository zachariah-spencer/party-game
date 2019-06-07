extends Camera2D

export var default_zoom_mod = 1.25

func _ready():
	pass # Replace with function body.

var center = Vector2.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	center = Vector2.ZERO
	var alive = 0
	for player in Players.active_players :
		if !player.is_dead():
			center += player.child.global_position
			alive += 1
#		var screen_pos = player.child.get_global_transform_with_canvas().origin
#		print(screen_pos)
#		var screen_size = get_viewport_rect().size
#		if abs(screen_pos.x) > screen_size.x :
#			zoom += Vector2.ONE*.01
#		if abs(screen_pos.y) > screen_size.y :
#			zoom += Vector2.ONE*.01
	center = center/alive
	var zoom_in = false
	var zoom_out = false
	var dist = 0
	for player in Players.active_players :
		if !player.is_dead():
			dist += center.distance_to(player.child.global_position)

	if alive > 1 :
		zoom = lerp(zoom, Vector2.ONE * max(.1,log(dist)/log(40)-.3), .5)
	else :
		zoom = Vector2.ONE * default_zoom_mod
	global_position = center

