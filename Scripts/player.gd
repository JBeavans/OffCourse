extends CharacterBody2D

signal ballPlaced
signal swingTriggered
signal ballPicked
signal printData
signal requestTeePosition
signal bagPlaced
signal bagPicked
signal cameraAdjusted
signal toggleVendInstructions
signal toggleBallHighlight

const SPEED = 50.0
var _ballCount = 0
var idleDirection: Vector2 #(0,1) #default idle to look down
var _spriteSize: Vector2
var _offsetToFeet: int
var _isInTeeBox: bool = false
var _ballOnTee: int = 0
var _isTee: bool
var _teePosition: Vector2
var _atVendor: bool
var _atBag: bool
var _bagEquiped: bool = true #temporary starting variable for testing
var _bag: Node2D
var _cameraPanning: bool = false


@onready var char_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var stats_label: Label = $StatsLabel
@onready var ball_finder_area: Area2D = $BallFinderArea


func _ready() -> void:
	_spriteSize = $CollisionShape2D.shape.get_rect().size
	_offsetToFeet = _spriteSize.y #/ 2 - commented out since the collision shape was changed to occupy only the space below the player's waist	
	
func _process(delta: float) -> void:
	stats_label.text = "Balls: " + str(_ballCount)
	var targetBallID: int
	
	#TODO: break code out into smaller functions
	if isStationary():
		targetBallID = isFacingBall()
		if targetBallID:
			#highlight ball
			toggleBallHighlight.emit(targetBallID)
		if Input.is_action_just_pressed("look_down", false) and not _cameraPanning:
			#update player data
			#signal to OpenWorld that player wants to swing
			swingTriggered.emit(isFacingBall())
			#get_tree().change_scene_to_file("res://Scenes/swingView.tscn")
			
		if Input.is_action_just_pressed("interact_ball"):
			var id = isFacingBall()
			if isInTeeBox():
				toggle_ball_on_tee()
			elif id:
				pick_up_ball(id)
			else:
				#decide where the ball will go. *update to include a random "drop zone"*
				var ballPosition = position + (idleDirection * 3)
				ballPosition.y += _offsetToFeet + 3 #shifting the ball down a smidge (TODO: factor in this adjustment in the calculation of the offset variable)
				ballPosition.x += idleDirection.x * _spriteSize.x
				place_ball(ballPosition)
				
		if Input.is_action_just_pressed("list"):
			printData.emit()
		
		if Input.is_action_just_pressed("vend"):
			if _atVendor:
				_ballCount += 5
				print("balls in bag: " + str(_ballCount))
				
		if Input.is_action_just_pressed("bag") and not _cameraPanning:
			if _bagEquiped:
				place_bag()
			elif _atBag:
				pick_up_bag()
		
	else:
		#remove highlight from previously selected ball
		targetBallID = 0
		toggleBallHighlight.emit(targetBallID)
				


func _physics_process(delta: float) -> void:
	
	# TODO: break sections up into individual functions to be called
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		idleDirection = direction
	
	# Set animations based on updated direction
	if idleDirection == Vector2.UP:
		char_animation.play("idleUp")
		ball_finder_area.rotation_degrees = 180.0
		
	elif idleDirection.x > 0 && idleDirection.x < 1 && idleDirection.y < 0 && idleDirection.y > -1: #using a range since checking for the specific float printed didn't work
		char_animation.play("idleNE")
		ball_finder_area.rotation_degrees = -135.0
	elif idleDirection == Vector2.RIGHT:
		char_animation.play("idleRight")
		ball_finder_area.rotation_degrees = -90.0
	elif idleDirection.x > 0 && idleDirection.x < 1 && idleDirection.y > 0 && idleDirection.y < 1:
		char_animation.play("idleSE")
		ball_finder_area.rotation_degrees = -45.0
	elif idleDirection == Vector2.DOWN:
		char_animation.play("idleDown")
		ball_finder_area.rotation_degrees = 0.0
	elif idleDirection.x < 0 && idleDirection.x > -1 && idleDirection.y > 0 && idleDirection.y < 1:
		char_animation.play("idleSW")
		#print(direction.angle())
		ball_finder_area.rotation_degrees = 45.0
	elif idleDirection == Vector2.LEFT:
		char_animation.play("idleLeft")
		ball_finder_area.rotation_degrees = 90.0
	elif idleDirection.x < 0 && idleDirection.x > -1 && idleDirection.y < 0 && idleDirection.y > -1:
		char_animation.play("idleNW")
		ball_finder_area.rotation_degrees = 135.0
	
	velocity = direction * SPEED
	
	move_and_slide()

func place_ball(ballPosition: Vector2):
	#check if player has a ball
	if _ballCount > 0:
		#send a signal to OpenWorld parent to create a new ball
		ballPlaced.emit(ballPosition)
		#update how many balls the player has
		_ballCount -= 1
		print("You placed your ball at: " + str(ballPosition))
		print("balls in bag: " + str(_ballCount))
	else:
		#update this error message to display to the player 
		print("You are out of balls.")
		
func pick_up_ball(id: int) -> void:
		#handle logic to determine if player can pick up ball here (i.e. ball is in bounds or ball belongs to another player)
		ballPicked.emit(id)
		_ballCount += 1
		print("balls in bag: " + str(_ballCount))
		#future me probably needs to store ballCount in PlayerData only after checking that the pickup was succesful
	
func place_bag() -> void:
	#signal to OW position to place bag (playerPosition + 11.9px * directionVector)
	var bagPlacement = position + 11.9 * idleDirection #TODO: update hardcoded value to variable = to pick-up range (interactor area width/2?)
	bagPlaced.emit(bagPlacement)
	_bagEquiped = false
	#adjust camera so that bottom of the frame can't go lower than the bag + player height
	#(TODO: adjust camera to maximize view towards the nearest flag)
	_cameraPanning = true
	var screenSize = get_viewport_rect().end - _spriteSize * 6 # leave some room for the player
	var offsetDirection = idleDirection
	#check if direction is diagonal
	if abs(offsetDirection.x) + abs(offsetDirection.y) > 1:
		#treat screen size as if it were a square
		screenSize.x = min(screenSize.x, screenSize.y)
		screenSize.y = screenSize.x
		#adjust offset direction vector so we can work with 1's instead of decimals
		offsetDirection = offsetDirection / abs(offsetDirection)
		
	var newOffset = screenSize * offsetDirection / 4

	while (abs($Camera2D.get_offset().y) < abs(newOffset.y) or abs($Camera2D.get_offset().x) < abs(newOffset.x)): #this is not a correct calculation - should compare to screen size
		if _bagEquiped: break
		$Camera2D.set_offset($Camera2D.get_offset() + offsetDirection)
		#print("Camera offset: " + str($Camera2D.get_offset()) + "\tnewOffset: " + str(newOffset) + "\toffsetDirection: " + str(offsetDirection))
		await get_tree().create_timer(0.005).timeout
	
	cameraAdjusted.emit(newOffset)
	_cameraPanning = false

func pick_up_bag() -> void:
	#signal to OW to remove bag
	bagPicked.emit(_bag) #need to pass bag node
	_bagEquiped = true
	#realign camera to center on player
	_cameraPanning = true
	var offset = $Camera2D.get_offset()
	#print("camera offset at pickup: " +  str(offset))
	#calculate offset direction vector from current offset so we can work with 1's
	var reverseOffsetDirection: Vector2
	if (offset.x != 0):
		reverseOffsetDirection.x = -offset.x / abs(offset.x)
	if (offset.y != 0):
		reverseOffsetDirection.y = -offset.y /abs(offset.y)
	#print("reverseOffsetDirection: " +  str(reverseOffsetDirection))
	print("bag pick signal emitted with argument: " + str(_bag))
	while ($Camera2D.get_offset() != Vector2.ZERO and _bagEquiped):
		$Camera2D.set_offset($Camera2D.get_offset() + reverseOffsetDirection)
		await get_tree().create_timer(0.005).timeout
	cameraAdjusted.emit(Vector2.ZERO)
	_cameraPanning = false

func isStationary():
	return velocity == Vector2.ZERO
	
func isFacingBall() -> int:
	#temp return until methodology is determined
	#returns id of nearest ball within searchable range (based on direction and TODO:player's stats)
	var areas = ball_finder_area.get_overlapping_areas()
	var max_range = 21*21 
	var closestBall: Ball
	for area in areas:
		if area is FindableArea:
			var range = ball_finder_area.position.distance_squared_to(area.position)
			if range < max_range:
				closestBall = area.get_parent()
				max_range = range
				
	if not closestBall == null:
		closestBall.isHighlighted = true
		#	print("is facing " + str(closestBall.id))
		return closestBall.id
	#print("is facing " + str(obj)) #this is getting called every frame right now - TODO: be more conservative with calling isFacingBall()
	return 0 
	
func setDirection(dir: Vector2) -> void:
	idleDirection = dir

func setBallCount(numBalls: int) -> void:
	_ballCount = numBalls
	
func isInTeeBox() -> bool:
	return _isInTeeBox
	
func getBallOnTee() -> int:
	return _ballOnTee
	
func toggle_ball_on_tee():
	var id = getBallOnTee()
	if id:
		pick_up_ball(id)
	else:
		place_ball(_teePosition + Vector2(0, -0.75))
		


func _on_tee_box_area_body_entered(body: Node2D) -> void:
	if body == self:
		_isInTeeBox = true
		print("You entered tee box\n")
		requestTeePosition.emit() #likely will need to send playerID once multiplayer is in development
		#TODO: add a mechanic to move pan the camera up to give the player a better view of the where they're aiming
	elif body.is_in_group("balls"):
		_ballOnTee = body.id
		print("ball id: " + str(_ballOnTee) + " on tee")
	#else:
		#print(body.name + " entered tee box")


func _on_tee_box_area_body_exited(body: Node2D) -> void:
	if body == self:
		_isInTeeBox = false
		print("You exited the tee box\n")
		#TODO: complete the camera moving mechanic by moving it back to its original position relative to the player
	elif body.is_in_group("balls"):
		_ballOnTee = 0


func _on_tee_box_send_tee_position(pos: Vector2) -> void:
	#print("Tee Position: " + str(pos))
	if not pos == null:
		_isTee = true
	else:
		_isTee = false
		
	_teePosition = pos


func _on_vendor_interactor_area_body_entered(body: Node2D) -> void:
	if body == self:
		_atVendor = true
		toggleVendInstructions.emit()

func _on_vendor_interactor_area_body_exited(body: Node2D) -> void:
	if body == self:
		_atVendor = false
		toggleVendInstructions.emit()


func _on_bag_interact_entered(body: Node2D, bag: Node2D) -> void:
	if body == self:
		_atBag = true
		_bag = bag
		print("Press B to pick up bag")


func _on_bag_interact_exited(body: Node2D) -> void:
	if body == self:
		_atBag = false
