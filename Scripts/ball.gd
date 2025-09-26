class_name Ball
extends RigidBody2D

signal ballMoved
signal ballStopped

const SPEED = 12.5

var velocity: Vector2 #actually new position based on velocity
var id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("balls")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not velocity == Vector2.ZERO:
		var prev_pos:= position
		#move_and_collide(velocity * delta)
		position = position.move_toward(velocity, delta * SPEED)
		if prev_pos == position:
			velocity = Vector2.ZERO
			ballStopped.emit()
			
		ballMoved.emit(position, velocity)
