extends Area2D



func _on_LazarHazard_body_entered(body):
	var player = body as Player

	if player:
		player.hit(self, 100, Vector2(0,-250), Damage.ENVIRONMENTAL)
