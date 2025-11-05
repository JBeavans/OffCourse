class_name Ball
extends RigidBody2D

signal ballMoved
signal ballStopped

#const SPEED = 12.5
var hasVelocity: bool = false
var dir2D: Vector2 # new position based on launch velocity
var id: int
var speed: float = 0.0
var isHighlighted: bool = false
var restingPos: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("balls")
	restingPos = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	$BallSprite/HighlightSprite.visible = isHighlighted
	
	if hasVelocity:
		isHighlighted = false
		#var prev_pos:= position
		##move_and_collide(velocity * delta)
		#position = position.move_toward(dir2D, delta * speed)
		##if prev_pos == position:
			##hasVelocity = false
			##dir2D = Vector2.ZERO
			##ballStopped.emit()
			#
		#ballMoved.emit(position, dir2D)
	elif restingPos != position:
		restingPos = position

func on_connectionTest():
	print("connection test passed!!!!!!!!!!!!!!!!!!!!!!!!")

func connectToFlightPath() -> void:
	$FlightPath.testConnected.connect(on_connectionTest)
	$FlightPath.updateBall.connect(on_flightpath_updateBall)

func on_flightpath_updateBall(distance: float, height: float, time: float):
	
	var flightScaling:= 0.5 + height/20.0
	#if height > 0:
		#flightScaling = 0.75 
	$BallSprite.scale = Vector2(flightScaling, flightScaling)
	if distance:
		#print("hang time: " , time, " distance (px): ", distance)
		position = restingPos + distance * dir2D
		ballMoved.emit(position, dir2D)
	else:
		hasVelocity = false
		dir2D = Vector2.ZERO
		ballStopped.emit()
	
