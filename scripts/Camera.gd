extends Camera2D

export var default_zoom_mod = 1.25

func _ready():
	pass # Replace with function body.

var center = Vector2.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	center = Vector2.ZERO
	var alive = 0
	for player in Players._get_alive_players():
		center += player.child.global_position
		alive += 1
	
	if alive > 0 : center = center/alive
	var zoom_in = false
	var zoom_out = false
	var dist = 0
	for player in Players._get_alive_players():
		dist += center.distance_to(player.child.global_position)
	if alive > 1 :
		zoom = lerp(zoom, Vector2.ONE * max(.1,log(dist)/log(40)-.3), .5)
	else :
		zoom = Vector2.ONE * default_zoom_mod
	global_position = center
	
