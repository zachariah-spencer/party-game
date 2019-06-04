extends CanvasLayer

func _enter_tree():
	$AnimationPlayer.play("fade")
	yield(get_tree().create_timer(1.5),'timeout')
	free()

func _transition_scene():
	Manager.current_game_reference.get_node('SpawnPoints').free()
	Manager.current_game_reference.queue_free()
	get_parent().add_child(Manager.finish_transition_instance)
	