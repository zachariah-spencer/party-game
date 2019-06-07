extends Camera2D

export var default_zoom_mod = 1.25
var alive = 0
var center = Vector2.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	center = Vector2.ZERO
	alive = 0
	for player in Players._get_alive_players():
		center += player.child.global_position
		alive += 1
	print(alive)
	if alive > 0 : center = center/alive

	var dist = 0
	for player in Players._get_alive_players():
		dist += center.distance_to(player.child.global_position)
	if alive > 1 :
		zoom = lerp(zoom, Vector2.ONE * max(.1,log(dist)/log(40)-.3), .5)
	else :
		zoom = Vector2.ONE * default_zoom_mod
	global_position = center

