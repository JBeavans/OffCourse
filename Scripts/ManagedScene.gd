class_name ManagedScene extends Node2D

signal stateSaved
signal sceneChanged

var _data: OpenWorldData
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func importData(data: OpenWorldData) -> void:
	_data = data
	print("%s imported data" % self.name)
