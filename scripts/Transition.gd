extends CanvasLayer

signal covered
export var game_opening_fade := false

func _ready():
	if game_opening_fade:
		$AnimationPlayer.play("fade_out")
	else:
		$AnimationPlayer.play("fade_in")
		yield($AnimationPlayer, "animation_finished")
		emit_signal("covered")

func fade_out():
	$AnimationPlayer.play("fade_out")
	yield($AnimationPlayer, "animation_finished")
	queue_free()