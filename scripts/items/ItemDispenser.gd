extends Item

export var item_path := "res://scenes/items/Grenade.tscn"
var item : PackedScene
onready var dispense_sound := $Dispense

func _ready():
	item = load(item_path)

func grab(by):
	dispense_sound.play()
	by.set_item(item.instance())