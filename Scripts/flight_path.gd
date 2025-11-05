class_name FlightPath extends Node2D

signal testConnected
signal updateBall

const GRAVITY = 9.8
const M_TO_YD = 1.0936133
const PX_PER_YD = 4.5

var _launchVel: float
var _launchAngle: float #in radians
var _flightTime: float
var _distance: float
var _yVel0: float
var _xVel0: float
var _simTime:= 0.0
var _maxSimTime:= 0.0
var pointScene: PackedScene = load("res://Scenes/point.tscn")
var pathOrigin: Vector2
var timeScale: float
#var distanceScale: float
var heightScale: float
var _timeReportNeeded: bool = false
var _terminalVelocity: float

var heightLabelYOrigin: float
var distanceLabelXOrigin: float
var x_previous := -1.0
var ballStopped := false

@onready var graphBackground: Sprite2D = $FlightPathBackground
@onready var heightLabel: Label = $HeightLabel
@onready var distanceLabel: Label = $DistanceLabel


#initialize with ball's launch velocity and angle
func setup(launchConditions: Vector2) -> void:
	#_launchVel = launchConditions.x
	#_launchAngle = deg_to_rad(launchConditions.y)
	#_yVel0 = _launchVel * sin(_launchAngle)
	#_xVel0 = _launchVel * cos(_launchAngle)
	#calculateTerminalVelocity()
	#_flightTime = 2 * _yVel0 / GRAVITY # 2 * time to peak of flight [Vy = 0]
	#calculateFlightTimeWithDrag()
	$FlightPathSolver.solve(launchConditions)
	_flightTime = $FlightPathSolver.time_total
	_distance = $FlightPathSolver.distance
	_maxSimTime = $FlightPathSolver.t
	print("flight time: " + str(_flightTime))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	testConnected.emit()
	#$FlightPathSolver.solve()
	print("graph scale: " + str(graphBackground.scale))
	print("graph position: " + str(graphBackground.position))
	pathOrigin.x = graphBackground.position.x + graphBackground.scale.x / 2
	pathOrigin.y = graphBackground.position.y + graphBackground.scale.y / 2
	timeScale = graphBackground.scale.x / 40.0
	heightScale = graphBackground.scale.y / 45.0 #194.0625 * 2.5 # denominator represents max height (in m)
	#distanceScale = graphBackground.scale.x / 345.0 #denominator represents max distance (in m)
	heightLabelYOrigin = heightLabel.position.y
	distanceLabelXOrigin = distanceLabel.position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_simTime += delta
	#print("time elapsed: " + str(floori(_simTime*1000)))
	#var y = calculateHeightWithDrag() #calculateBallHeight()
	#var x = calculateDistanceWithDrag()
	var pathPosition: Vector2 = $FlightPathSolver.positions[floori(minf(_simTime, _maxSimTime)*1000)]
	#currently only checking if ball has not struck the ground again, but eventually need to calculate a second bounce or roll and base it on x velocity
	if pathPosition.y >= 0:
		#check if ball has stopped rolling by checking if the current path position is the same as the previous path position (using math on known variables instead of adding a new one)
		if pathPosition.x == x_previous and not ballStopped:
			updateBall.emit(0,0,0)
			ballStopped = true
		else:
			updateBall.emit(convertToPx(pathPosition.x) , convertToPx(pathPosition.y), _simTime)
		var point = pointScene.instantiate()
		point.position = Vector2(pathOrigin.x - pathPosition.x * heightScale, -1 * pathPosition.y * heightScale + pathOrigin.y) #substituted distance for time
		#print("point" + str(point.position))
		add_child(point)
		heightLabel.text = "< " + str(snapped(pathPosition.y * M_TO_YD, 0.1)) + " yds"
		heightLabel.position.y = heightLabelYOrigin - pathPosition.y * heightScale
		distanceLabel.text = "^ " + str(snapped(pathPosition.x * M_TO_YD, 0.1)) + " yds"
		distanceLabel.position.x = distanceLabelXOrigin - pathPosition.x * heightScale
		_timeReportNeeded = true
	elif (_timeReportNeeded):
		print("simTime: " + str(_simTime))
		#print("flightTime: " + str(_flightTime))
		_timeReportNeeded = false
	#update the last x position
	x_previous = pathPosition.x
#func calculateBallHeight() -> float:
	#var y = _yVel0*_simTime - (GRAVITY*_simTime*_simTime)/2
	#return y

#func calculateTerminalVelocity():
	#var mass = 45.5 #grams
	#var c_d = 0.33 #coefficient of drag
	#var diameter = 42.7 #mm
	#var area = PI * diameter * diameter / 4 #pi*r^2
	#var rho = 1.225 #kg/m^3 density of air at sea level
	#
	##convert mass from g to kg
	#mass = mass / 1000
	##convert area from mm2 to m2
	#area = area / 1000 / 1000
	#
	#_terminalVelocity = sqrt(2 * mass * GRAVITY / c_d / rho / area)
	##print("terminal velocity: " + str(_terminalVelocity))
	
func getXVel0() -> float:
	return _xVel0
	
func getYVel0() -> float:
	return _yVel0
	
#func calculateYVel() -> float:
	##breaking the equation from NASA's website down into smaller pieces for clarity and debugging if necessary
	##https://www1.grc.nasa.gov/beginners-guide-to-aeronautics/flight-equations-with-drag/
	#
	#var tangent = tan(_simTime * GRAVITY / _terminalVelocity)
	#var numerator = getYVel0() - _terminalVelocity * tangent
	#var denominator = _terminalVelocity + getYVel0() * tangent
	#var v = _terminalVelocity * numerator / denominator
	#
	#return v
	
#func calculateHeightWithDrag() -> float:
	##breaking the equation from NASA's website down into smaller pieces for clarity and debugging if necessary
	##https://www1.grc.nasa.gov/beginners-guide-to-aeronautics/flight-equations-with-drag/
	#
	##TODO: perform separate calculations for ascent and descent
	#var numerator = getYVel0()**2 + _terminalVelocity**2
	#var denominator = calculateYVel()**2 + _terminalVelocity**2
	#var y = _terminalVelocity**2 / 2 / GRAVITY * log(numerator / denominator)
	##print ("yVel = " + str(calculateYVel()))
	#return y
	
#func calculateDistanceWithDrag() -> float:
	##breaking the equation from NASA's website down into smaller pieces for clarity and debugging if necessary
	##https://www1.grc.nasa.gov/beginners-guide-to-aeronautics/flight-equations-with-drag/
	#var numerator = _terminalVelocity**2 + GRAVITY * getXVel0() * _simTime
	##print("distance numerator:" + str(numerator))
	#var denominator = _terminalVelocity**2
	#var x = _terminalVelocity**2 / GRAVITY * log(numerator / denominator)
	##print("x = " + str(x))
	#
	#return x

#func calculateFlightTimeWithDrag():
	##derived from equation from NASA's website
	##https://www1.grc.nasa.gov/beginners-guide-to-aeronautics/flight-equations-with-drag/
	#_flightTime = 2 * _terminalVelocity / GRAVITY * atan(getYVel0()/ _terminalVelocity) #may be better to use atan2(yvel0,terminal)?
	
func getFlightTime() -> float:
	return _flightTime
	
func getDistance() -> float:
	return _distance * PX_PER_YD

func convertToPx(meters: float) -> float:
	return meters * M_TO_YD * PX_PER_YD
