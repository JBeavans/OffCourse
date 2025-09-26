extends RigidBody2D

signal hit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	print("ball freed")


func _on_club_ball_struck(launchConditions: Vector2) -> void:
	print('ball received on club ball struck signal')
	print('launch vel: ' + str(launchConditions.x))
	$CollisionShape2D.set_deferred("disabled", true)
	move_and_collide(Vector2(launchConditions.x * 10, 0))
