extends CharacterBody2D

signal ballStruck
signal accChanged
signal swingToggled

@onready var velocity_label: Label = $"../velocityLabel"

@onready var swing_sound: AudioStreamPlayer2D = $"../swingSound"

const SPEED_SCALE = 0.02
const MAX_V = 180
var x0: float
var velX0:= 0.0
#var zVel: float
var launchAngle:= 20.0 #degrees
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	## calculate swing physics based on mouse movement
	#set a variable that allows us to access the mouse's relative coordinates
	var camera = get_viewport().get_camera_2d()
	
	#when the player left-clicks, set their initial x position and send a signal to start the swing sound
	if Input.is_action_just_pressed("swing"):
		x0 = camera.get_global_mouse_position().x
		swingToggled.emit()
	#track the mouse's x position while LMB is held down
	#use this to calculate velocity and acceleration
	if Input.is_action_pressed("swing"):
		var x1 = camera.get_global_mouse_position().x
		var dx = x1 - x0 
		var velX1 = dx / delta * SPEED_SCALE
		var a = int((velX1 - velX0) / delta)
		#the stepSize variable controls how often we emit the accChanged signal to alter the swing sound
		#currently it functions, but likely not how I expect since the math doesn't make sense to me
		var stepSize = a % 100
		if stepSize > 10:
			print(stepSize)
			accChanged.emit(int(a))
		
		velocity_label.text = "V0: "+ str(velX0) + "\nV1: " + str(velX1) + "\nA: " + str(a)
		#update starting position variables
		x0 = x1
		velX0 = velX1
		
		#create a deadzone (based on a guess)
		#if dx < 10 && dx > -25:
			#dx = 0
			
		#guessing on this equation TODO:-> update later w/ a ball spin calculation
		
		velocity.x = velX1 # dx * SPEED * delta
		var collision = move_and_collide(velocity)
		if (collision): 
			print(collision.get_collider())
			#TODO: create a formula that updates based on club attributes
			var launchVelocity = max(velocity.x * 1.5, -MAX_V)
			
			#send the launchConditions
			ballStruck.emit(Vector2(launchVelocity, launchAngle))
	
	#reset the club when the user releases the LMB and stop the swing sound
	elif Input.is_action_just_released("swing"):
		velocity.x = 0
		position.x = 23
		swingToggled.emit()
