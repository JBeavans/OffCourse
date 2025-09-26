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
	# Add the gravity.
	#if not is_on_floor():
	#	velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# calculate swing based on mouse movement
	var camera = get_viewport().get_camera_2d()
	if Input.is_action_just_pressed("swing"):
		x0 = camera.get_global_mouse_position().x
		swingToggled.emit()
	if Input.is_action_pressed("swing"):
		var x1 = camera.get_global_mouse_position().x
		var dx = x1 - x0 
		var velX1 = dx / delta * SPEED_SCALE
		var a = int((velX1 - velX0) / delta)
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
			
		#guessing on this equation -> update later w/ a rotation calculation
		
		velocity.x = velX1 # dx * SPEED * delta
		var collision = move_and_collide(velocity)
		if (collision): 
			print(collision.get_collider())
			#create a formula that updates based on club attributes
			var launchVelocity = max(velocity.x * 1.5, -MAX_V)
			#zVel = launchVelocity.x * sin(deg_to_rad(launchAngle))
			#print("\nlaunch velocity: " + str(launchVelocity))
			#print("\nz vel: " + str(zVel))
			ballStruck.emit(Vector2(launchVelocity, launchAngle))
		
		#self.position.x += dx * delta * SPEED
	elif Input.is_action_just_released("swing"):
		velocity.x = 0
		position.x = 23
		swingToggled.emit()
