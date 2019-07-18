extends Node2D

export var speed := 0.1

func _physics_process(delta):
	rotation += speed