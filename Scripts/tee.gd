extends Node2D

signal teePlaced

var _topOfTee: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_topOfTee.x = position.x
	_topOfTee.y = position.y - $TeeSprite.scale.y/2
	teePlaced.emit(_topOfTee)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
