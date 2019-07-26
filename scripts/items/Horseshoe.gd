extends Item

onready var shot_landed_area := $ShotLandedArea
onready var fall_timer := $FallTimer
onready var grenade = preload('res://scenes/items/ContactGrenade.tscn')
onready var anim := $AnimatedSprite
var landed := false
var target
var frame_count := 0
var landed_pos : Vector2
var has_been_moved := false

signal made_shot

func _ready():
	connect('made_shot', Manager.current_minigame, 'on_made_shot')
	_weight = 4
	if _owner == null:
		anim.play('landed')
	else:
		anim.play('held')

func _on_grab():
	if anim:
		sprite.visible = false
		anim.play('held')

func _on_throw():
	anim.play('airborne')
	sprite.visible = false

func _integrate_forces(state):

	if landed && !has_been_moved:
		angular_velocity = 0
		rotation = 0
		linear_velocity.x = 0
		has_been_moved = true

func _on_ShotLandedArea_area_entered(area):
	target = area.get_parent()
	
	if !landed:
		anim.play('landed')
		$LandedSFX.play()
		landed = true
		fall_timer.start()
		target.stack.append(self)
		grabbable = false
		set_collision_mask_bit(4, true)

		if target.stack.size() > 4:
#			target.item_spawn_pos.position.y -= 20
#			target.area_shape.position.y -= 12
#			target.sprite.position.y -= 14
			target.stack[0].queue_free()
			target.stack.pop_front()
			for i in target.stack:
				i.position.y += 3

		get_parent().remove_child(self)
		position = Vector2.ZERO + Vector2(0,-20)
		rotation = 0
		target.call_deferred("add_child", self)

		emit_signal('made_shot', _owner)

func _on_FallTimer_timeout():
	mode = RigidBody2D.MODE_KINEMATIC


func _on_Horseshoe_body_entered(body):
	var terrain = body if body.get_collision_layer_bit(0) == true else null
	if terrain:
		anim.play('landed')
		$CollisionSFX.play()