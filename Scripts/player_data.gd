class_name PlayerData extends Node

var playerName: String
var pos: Vector2
var dir: Vector2
var balls: Array[int] #should contain a list of ballIDs belonging to the player

func _init() -> void:
	balls = []
	pos = Vector2.ZERO
	dir = Vector2.ZERO
