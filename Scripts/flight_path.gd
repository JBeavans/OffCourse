class_name FlightPath extends Node2D

const GRAVITY = 9.8

var _launchVel: float
var _launchAngle: float #in radians
var _flightTime: float
var _yVel: float
var _xVel: float
var _simTime:= 0.0
var pointScene: PackedScene = load("res://Scenes/point.tscn")
var pathOrigin: Vector2
var timeScale: float
var heightScale: float
var _timeReportNeeded: bool = false

@onready var graphBackground: Sprite2D = $FlightPathBackground


#initialize with ball's launch velocity and angle
func setup(launchConditions: Vector2) -> void:
	_launchVel = launchConditions.x
	_launchAngle = deg_to_rad(launchConditions.y)
	_yVel = -_launchVel * sin(_launchAngle)
	_xVel = _launchVel * cos(_launchAngle)
	_flightTime = 2 * _yVel / GRAVITY # 2 * time to peak of flight [Vy = 0]
	print("flight time: " + str(_flightTime))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#graphSize = graphBackground.
	print("graph scale: " + str(graphBackground.scale))
	print("graph position: " + str(graphBackground.position))
	pathOrigin.x = graphBackground.position.x + graphBackground.scale.x / 2
	pathOrigin.y = graphBackground.position.y + graphBackground.scale.y / 2
	timeScale = graphBackground.scale.x / 40.0
	heightScale = graphBackground.scale.y / 1000.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_simTime += delta
	var y = calculateBallHeight()
	#currently only checking if ball has not struck the ground again, but eventually need to calculate a second bounce or roll and base it on x velocity
	if y >= 0:
		var point = pointScene.instantiate()
		point.position = Vector2(pathOrigin.x - _simTime * timeScale, -1 * y * heightScale + pathOrigin.y)
		#print("point" + str(point.position))
		add_child(point)
		_timeReportNeeded = true
	elif (_timeReportNeeded):
		print("simTime: " + str(_simTime))
		print("flightTime: " + str(_flightTime))
		_timeReportNeeded = false

func calculateBallHeight() -> float:
	var y = _yVel*_simTime - (GRAVITY*_simTime*_simTime)/2
	return y
	
func getXVel() -> float:
	return _xVel
	
func getYVel() -> float:
	return _yVel
	
func getFlightTime() -> float:
	return _flightTime
