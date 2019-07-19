extends Item

export var item_path := "res://scenes/items/Grenade.tscn"
var item : PackedScene
var original_scale : Vector2
onready var display_sprite = $Display
onready var dispense_sound := $Dispense
onready var tween := $Tween

func _ready():
	item = load(item_path)
	var setup_item = item.instance()
	display_sprite.texture = setup_item.get_node('Obj/Sprite').get_texture()
	display_sprite.scale = setup_item.get_node('Obj/Sprite').get_scale()
	original_scale = display_sprite.scale
	tween.interpolate_property(display_sprite,'scale',display_sprite.scale,display_sprite.scale - Vector2(.08,.08), 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	

func grab(by):
	dispense_sound.play()
	by.set_item(item.instance())


func _on_Tween_tween_completed(object, key):
	if display_sprite.scale < original_scale:
		tween.interpolate_property(display_sprite,'scale',display_sprite.scale,display_sprite.scale + Vector2(.08,.08), 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	else:
		tween.interpolate_property(display_sprite,'scale',display_sprite.scale,display_sprite.scale - Vector2(.08,.08), 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
