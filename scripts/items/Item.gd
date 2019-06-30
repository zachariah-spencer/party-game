extends RigidBody2D
class_name Item

var _held
var _owner
onready var sprite = $Obj/Sprite
var _weight := 0
export var throwable := true
export var grabbable := true

enum hit_types { opponents, everybody, terrain, terrain_no_platforms }

var hits = hit_types.opponents

signal grabbed
signal thrown


func _ready():
	connect("body_entered" , self, "_on_body_entered")
	$Pickup_area.add_to_group("item")

func _on_body_entered(body):
	pass


func grab(by):
	if grabbable:
		_owner = by
		sprite.modulate = _owner.modulate
		emit_signal("grabbed")
		mode = MODE_STATIC
		collision_layer = 0
		$Pickup_area.monitorable = false

func throw(direction : Vector2, pos : Vector2 , by):
	if throwable:
		_owner = by
		sprite.modulate = _owner.get_parent().modulate
		mode = MODE_RIGID
		get_parent().remove_child(self)
		global_position = pos
		Manager.current_minigame.add_child(self)
		$Pickup_area.monitorable = true
		collision_layer = get_hit_mask(hit_types.opponents) + get_hit_mask(hit_types.terrain) + Globals.ITEM_BIT
		apply_central_impulse(direction)
		emit_signal("thrown")

func get_hit_mask(hit := hits):
	var mask = 0
	match hit :
		hit_types.opponents :
			if _owner :
				return Globals.PLAYER_BITS - _owner.parent.bit
			else : return Globals.PLAYER_BITS
		hit_types.everybody :
			return Players.player_bits
		hit_types.terrain :
			return 17
		hit_types.terrain_no_platforms :
			return 1


func _deown():
	sprite.modulate = Color.white
	_owner = null

func hit(by : Node, damage : int, knockback :Vector2) :
	pass
