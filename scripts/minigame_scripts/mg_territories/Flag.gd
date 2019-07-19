extends Area2D

var owned_by : PlayersManager = null
export var start_owner := 0

onready var flag_flip_sfx := $FlagFlipped
onready var flip_tween := $Tween
signal flag_captured
signal flag_deowned

func _ready():
	match start_owner:
		1:
			owned_by = Players.player_one
		2:
			owned_by = Players.player_two
		3:
			owned_by = Players.player_three
		4:
			owned_by = Players.player_four
	
	
	connect('flag_captured', Manager.current_minigame,'_increase_local_score')
	connect('flag_deowned', Manager.current_minigame,'_decrease_local_score')
	connect('body_entered', self, '_on_InteractArea_body_entered')
	
	if owned_by:
		modulate = owned_by.modulate
		emit_signal('flag_captured', owned_by, 1)

func _on_InteractArea_body_entered(body):
	var player = body as Player
	
	if player && !Manager.current_minigame.game_over:
		_flag_flip(player.parent)

func _flag_flip(by : PlayersManager):
	if by != owned_by:
		flag_flip_sfx.play()
		flip_tween.interpolate_property(self, 'rotation', 0, 2 * PI, .3, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
		flip_tween.start()
		
		
		if owned_by:
			emit_signal('flag_deowned', owned_by, 1)
		
		if !owned_by:
			Manager.current_minigame.total_owned_flags += 1
		
		owned_by = by
		modulate = owned_by.modulate
		emit_signal('flag_captured', owned_by, 1)
