extends Area2D

onready var beam_hazard := $BeamHazard

signal level_completed

var completed_players := []

func _ready():
	connect('level_completed', Manager.current_minigame, '_on_level_completed')
	Players._update_active_players()

func _on_LevelCompleteZone_body_entered(body):
	var player = body as Player

	if player && !completed_players.has(player.parent):
		emit_signal('level_completed')
		completed_players.append(player.parent)
	
	if completed_players.size() == Players.active_players.size() - 1:
		beam_hazard.activate()
