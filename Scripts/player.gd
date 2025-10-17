extends CharacterBody2D

signal ballPlaced
signal swingTriggered
signal ballPicked
signal printData
signal requestTeePosition

const SPEED = 50.0
var ballCount = 5
var idleDirection: Vector2 #(0,1) #default idle to look down
var _spriteSize: Vector2
var _offsetToFeet: int
var _isInTeeBox: bool = false
var _ballOnTee: int = 0
var _isTee: bool
var _teePosition: Vector2


@onready var char_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast

func _ready() -> void:
	_spriteSize = $CollisionShape2D.shape.get_rect().size
	_offsetToFeet = _spriteSize.y #/ 2 - commented out since the collision shape was changed to occupy only the space below the player's waist	
	
func _process(delta: float) -> void:
	if isStationary():
		if Input.is_action_just_pressed("look_down", false):
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
		


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		idleDirection = direction
	
	# Set animations based on updated direction
	if idleDirection == Vector2.UP:
		char_animation.play("idleUp")
		ray_cast.rotation_degrees = 180.0
	elif idleDirection.x > 0 && idleDirection.x < 1 && idleDirection.y < 0 && idleDirection.y > -1: #using a range since checking for the specific float printed didn't work
		char_animation.play("idleNE")
		ray_cast.rotation_degrees = -135.0
	elif idleDirection == Vector2.RIGHT:
		char_animation.play("idleRight")
		ray_cast.rotation_degrees = -90.0
	elif idleDirection.x > 0 && idleDirection.x < 1 && idleDirection.y > 0 && idleDirection.y < 1:
		char_animation.play("idleSE")
		ray_cast.rotation_degrees = -45.0
	elif idleDirection == Vector2.DOWN:
		char_animation.play("idleDown")
		ray_cast.rotation_degrees = 0.0
	elif idleDirection.x < 0 && idleDirection.x > -1 && idleDirection.y > 0 && idleDirection.y < 1:
		char_animation.play("idleSW")
		#print(direction.angle())
		ray_cast.rotation_degrees = 45.0
	elif idleDirection == Vector2.LEFT:
		char_animation.play("idleLeft")
		ray_cast.rotation_degrees = 90.0
	elif idleDirection.x < 0 && idleDirection.x > -1 && idleDirection.y < 0 && idleDirection.y > -1:
		char_animation.play("idleNW")
		ray_cast.rotation_degrees = 135.0
	
	velocity = direction * SPEED
	
	move_and_slide()

func place_ball(ballPosition: Vector2):
	#check if player has a ball
	if ballCount > 0:
		#send a signal to OpenWorld parent to create a new ball
		ballPlaced.emit(ballPosition)
		#update how many balls the player has
		ballCount -= 1
		print("You placed your ball at: " + str(ballPosition))
	else:
		#update this error message to display to the player 
		print("You are out of balls.")
		
func pick_up_ball(id: int) -> void:
		#handle logic to determine if player can pick up ball here (i.e. ball is in bounds or ball belongs to another player)
		ballPicked.emit(id)
		ballCount += 1
		#future me probably needs to store ballCount in PlayerData only after checking that the pickup was succesful
	

func isStationary():
	return velocity == Vector2.ZERO
	
func isFacingBall() -> int:
	#temp return until methodology is determined
	#returns id of nearest ball within searchable range (based on direction and player's stats)
	var obj = ray_cast.get_collider()
	print("is facing " + str(obj))
	if obj is FindableArea:
		return obj.get_parent().id
	return 0 
	
func setDirection(dir: Vector2) -> void:
	idleDirection = dir

func setBallCount(numBallsInPlay: int) -> void:
	ballCount -= numBallsInPlay
	
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
	else:
		print(body.name + " entered tee box")


func _on_tee_box_area_body_exited(body: Node2D) -> void:
	if body == self:
		_isInTeeBox = false
		print("You exited the tee box\n")
		#TODO: complete the camera moving mechanic by moving it back to its original position relative to the player
	elif body.is_in_group("balls"):
		_ballOnTee = 0


func _on_tee_box_send_tee_position(pos: Vector2) -> void:
	print("Tee Position: " + str(pos))
	if not pos == null:
		_isTee = true
	else:
		_isTee = false
		
	_teePosition = pos
