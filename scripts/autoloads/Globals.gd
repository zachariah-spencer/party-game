extends Node
#warning-ignore-all:unused_class_variable

const GRAVITY = 2400
const UP = Vector2.UP
const CELL_SIZE = 32

var player_one
var player_two
var player_three
var player_four

var players = [player_one, player_two, player_three, player_four]

var HUD

func _ready():
	randomize()