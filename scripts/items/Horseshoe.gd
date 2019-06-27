extends Item

onready var shot_landed_area := $ShotLandedArea

func _ready():
	connect("thrown", self, "_on_throw")
	_weight = 4



func _on_ShotLandedArea_area_entered(area):
	var target = area
	
	print('landed a shot')
