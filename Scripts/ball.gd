class_name Ball
extends RigidBody2D

signal ballMoved
signal ballStopped

#const SPEED = 12.5
var hasVelocity: bool = false
var dir2D: Vector2 # new position based on launch velocity
var id: int
var speed: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("balls")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hasVelocity:
		var prev_pos:= position
		#move_and_collide(velocity * delta)
		position = position.move_toward(dir2D, delta * speed)
		if prev_pos == position:
			hasVelocity = false
			dir2D = Vector2.ZERO
			ballStopped.emit()
			
		ballMoved.emit(position, dir2D)
