class_name OpenWorldData extends Node

var balls: Array[BallData]
var playerData: PlayerData
var activeBallID: int
var ballsDict: Dictionary[int, BallData]

func _init() -> void:
	balls = []
	playerData = PlayerData.new()
	activeBallID = 0
	ballsDict = {}
