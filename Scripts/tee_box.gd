extends StaticBody2D

signal sendTeePosition

var _teePosition: Vector2
#var _knownBodies: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	##Coded this bit up as a way to try to debug colisions
	#var bodies: Array = $TeeBoxArea.get_overlapping_bodies()
	#for body in bodies:
		#if not body in _knownBodies:
			#_knownBodies.append(body)
			#print(str(body.name) + " is overlapping tee box")
	#var bodiesExited: Array[int]
	#var knownIndex: int = 0
	#for body in _knownBodies:
		#if not body in bodies:
			#bodiesExited.append(knownIndex)
		#else:
			#knownIndex += 1
	#var totalRemoved: int = 0
	#for index in bodiesExited:
		#var newIndex = index - totalRemoved
		#print(_knownBodies[newIndex].name + " was removed from the teeBox")
		#_knownBodies.remove_at(newIndex)
		#totalRemoved += 1
		

func _on_tee_tee_placed(teeTop: Vector2) -> void:
	_teePosition = teeTop + position
	pass # Replace with function body.


func _on_player_request_tee_position() -> void:
	sendTeePosition.emit(_teePosition)
