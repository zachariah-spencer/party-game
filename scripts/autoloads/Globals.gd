extends Node
#warning-ignore-all:unused_class_variable

const DEBUG := preload("res://scenes/ui/Debug_menu.tscn")

const GRAVITY : int = 2400
const UP : Vector2 = Vector2.UP
const CELL_SIZE : int = 32

const TERRAIN_BIT = 1
const LEFT_ARM_BIT = 2
const RIGHT_ARM_BIT = 4
const PLAYERS_BODIES_BIT = 8
const PLATFORM_BIT = 16
const P1_BIT = 64
const P2_BIT = 128
const P3_BIT = 256
const P4_BIT = 512
const CORPSE_BIT = 1024
const NO_PLAYER_WALL_BIT = 2048
const ITEM_BIT = 16384

const PLAYER_BITS = 960

var player_one : Node
var player_two : Node
var player_three : Node
var player_four : Node

var players : Array = [player_one, player_two, player_three, player_four]

var HUD : Node

func _ready():
	randomize()
