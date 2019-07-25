extends Node2D

export var size := 100
export var resolution := 200
export var countdown_time := 1
export var draw_gradient : Gradient
onready var countdown_timer = $Timer

var draw_color = Color.green
var percent_full := .75
func _ready():
	start()

func start(time := countdown_time):
	countdown_time = time
	countdown_timer.start(countdown_time)

func _draw():
	draw_circle_arc_poly(position, size, 0, percent_full * 360, draw_color)

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = resolution
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * (radius * .4))
	points_arc.invert()
	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func _process(delta):
	if not countdown_timer.is_stopped() :
		visible = true
		percent_full = countdown_timer.time_left/countdown_time
		draw_color = draw_gradient.interpolate(percent_full)
		update()
	else :
		visible = false