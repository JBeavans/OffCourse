extends StaticBody2D

signal bagInteractorEntered
signal bagInteractorExited


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bag_interactor_area_body_entered(body: Node2D) -> void:
	bagInteractorEntered.emit(body, self)
	print("bag area entered signal sent from bag")


func _on_bag_interactor_area_body_exited(body: Node2D) -> void:
	bagInteractorExited.emit(body)
	print("bag area exited signal sent from bag")
