extends Node
#warning-ignore-all:unused_class_variable

const GRAVITY : int = 2400
const UP : Vector2 = Vector2.UP
const CELL_SIZE : int = 32

var player_one : Node
var player_two : Node
var player_three : Node
var player_four : Node

var players : Array = [player_one, player_two, player_three, player_four]

var current_HUD : Node

func _ready():
    randomize()