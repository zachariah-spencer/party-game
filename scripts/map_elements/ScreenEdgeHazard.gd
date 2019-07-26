extends Hazard

var playerpos
var start = 0 #distance from left side when the player is at the far left
var travel = 500 #how far it moves as the player goes to the far right

func _process(delta):
    playerpos = Players.player_one.get_global_transform().origin
    var farleft = get_viewport().get_visible_rect().abs().position.x #get the x position of the left edge of the screen
    var farright = get_viewport().get_visible_rect().abs().end.x #get the x position of the right edge of the screen
    var player_fraction = (playerpos.x-farleft)/(farright-farleft) #position of the player, 0 being on the far left and 1 being far right
    transform.origin = get_parent().to_local(Vector2(farleft+start+(travel*player_fraction), playerpos.y)) #based on that, find a spot to put the hazardtor2(farleft+start+(travel*player_fraction), playerpos.y) #based on that, find a spot to put the hazard