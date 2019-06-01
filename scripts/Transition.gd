extends CanvasLayer

func _enter_tree():
	$AnimationPlayer.play("fade")

func _transition_scene():
	Manager.current_game_reference.queue_free()
	get_parent().add_child(Manager.finish_transition_instance)