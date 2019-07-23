extends Hazard

var num_of_focuses := 0
var center := Vector2.ZERO
var focal_points := []
var no_players := true
var has_centered := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	center = Vector2.ZERO

	focal_points = get_parent().get_parent().runners

	num_of_focuses = 0

	if focal_points.size() != 1 :
		for focal_point in focal_points:
			if focal_point.is_in_group('default_focus'):
				focal_points.remove(focal_points.find(focal_point))

	for focal_point in focal_points:
		center += focal_point.global_position
		num_of_focuses += 1
	if num_of_focuses > 0 : center = center / num_of_focuses

	var dist = 0

	for focal_point in focal_points:
		dist += center.distance_to(focal_point.global_position)

	global_position.x = lerp(global_position.x, center.x - 384, .1)