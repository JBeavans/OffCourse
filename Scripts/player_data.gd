class_name PlayerData extends Node

var playerName: String
var pos: Vector2
var dir: Vector2
var ballsInBag: int
var balls: Array[int] #should contain a list of ballIDs belonging to the player
var bagLocation: Vector2
var cameraOffset: Vector2
var club: String
var bagState #sort out variable typing later TODO: make a bagState data type

func _init() -> void:
	balls = []
	pos = Vector2.ZERO
	dir = Vector2.ZERO
