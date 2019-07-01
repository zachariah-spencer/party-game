extends Item


export var item_path := "res://scenes/items/"
var item : PackedScene

func _ready():
	item = load(item_path)

func grab(by):
	by.set_item(item.instance())