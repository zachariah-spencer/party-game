extends Lever

export var random := false
export var mirror := Vector2.ONE
export var directions = [ Vector2.UP, Vector2.DOWN]
var fields = []


func _ready():
	for child in get_children():
		if child is GravityField :
			fields.append(child)

func flip():
	.flip()
	for field in fields :
		if random :
			field.set_gravity_vector( Vector2(rand_range(-1,1), rand_range(-1,1)))
		else :
			var out_vec = field.gravity_vec
			if out_vec.x != 0 :
				out_vec.x *= -1
			if out_vec.y != 0 :
				out_vec.y *= -1
			field.set_gravity_vector(out_vec)