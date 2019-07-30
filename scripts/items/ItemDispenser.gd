extends Item

export var item_path := "res://scenes/items/Grenade.tscn"
var item : PackedScene
var original_scale : Vector2
onready var display_sprite = $Display
onready var dispense_sound := $Dispense

func _ready():
	item = load(item_path)
	var setup_item = item.instance()
	display_sprite.texture = setup_item.get_node('Obj/Sprite').get_texture()
	display_sprite.scale = setup_item.get_node('Obj/Sprite').get_scale()
	original_scale = display_sprite.scale - Vector2(.2,.2)

var t := 0.0

func _process(delta):
	t += delta
	display_sprite.scale = original_scale * (.15 * sin(t * 5) + 2.0)
	display_sprite.rotation += .01 * sin(t * 2.5)

func grab(by):
	dispense_sound.play()
	by.set_item(item.instance())
