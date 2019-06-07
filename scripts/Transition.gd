extends CanvasLayer

signal covered

func _ready():
	$AnimationPlayer.play("fade_in")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("covered")

func fade_out():
	$AnimationPlayer.play("fade_out")
	yield($AnimationPlayer, "animation_finished")
	queue_free()