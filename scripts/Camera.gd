extends Camera2D

export var default_zoom_mod := 1.50
var num_of_focuses := 0
var center := Vector2.ZERO
var focal_points := []
var no_players := true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	center = Vector2.ZERO
	
	no_players = true if Players._get_alive_players().size() < 1 else false
	
	focal_points = get_tree().get_nodes_in_group('focus')
	
	num_of_focuses = 0
	
	if !no_players:
		for focal_point in focal_points:
			
			if focal_point.is_in_group('default_focus'):
				focal_points.remove(focal_points.find(focal_point))
	else:
		zoom = Vector2.ONE * default_zoom_mod
	
	for focal_point in focal_points:
		center += focal_point.global_position
		num_of_focuses += 1
	if num_of_focuses > 0 : center = center / num_of_focuses
	
	var dist = 0
	
	for focal_point in focal_points:
		dist += center.distance_to(focal_point.global_position)
	if num_of_focuses > 1 :
		if dist < 860:
			zoom = lerp(zoom, Vector2.ONE * max(.1,log(dist)/log(40)-.3), .08)
		elif dist >= 860 && dist < 1300:
			zoom = lerp(zoom, Vector2.ONE * max(.1,log(dist * 5)/log(40)-.3), .08)
		elif dist >= 1300 && dist < 1800:
			zoom = lerp(zoom, Vector2.ONE * max(.1,log(dist * 10)/log(40)-.3), .08)
		elif dist >= 1800 && dist < 2300:
			zoom = lerp(zoom, Vector2.ONE * max(.1,log(dist * 20)/log(40)-.3), .08)
		elif dist >= 2300 && dist < 2700:
			zoom = lerp(zoom, Vector2.ONE * max(.1,log(dist * 35)/log(40)-.3), .08)
		elif dist >= 2700:
			zoom = lerp(zoom, Vector2.ONE * max(.1,log(dist * 45)/log(40)-.3), .08)
	
	global_position = center