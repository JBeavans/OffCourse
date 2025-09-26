extends Node

@export var activeScene: PackedScene
var _data: OpenWorldData
var _activeSceneNode: Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_activeSceneNode = activeScene.instantiate()
	add_child(_activeSceneNode)
	_activeSceneNode.stateSaved.connect(updateData)
	_activeSceneNode.sceneChanged.connect(changeScene)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func changeScene(nextScene: PackedScene) -> void:
	var nextSceneNode: Node = nextScene.instantiate()
	#nextSceneNode.importData(_data)
	if not _data == null:
		nextSceneNode.importData(_data)
	add_child(nextSceneNode)
	#var error = nextSceneNode.stateSaved.connect(updateData)
	#if(error):
		#print(error)
	#error = nextSceneNode.sceneChanged.connect(changeScene)
	#if (error):
		#print(error)
	_activeSceneNode.queue_free()
	_activeSceneNode = nextSceneNode
	var activeSceneName = str(_activeSceneNode.name)
	print(activeSceneName + " scene added")
	var error = _activeSceneNode.stateSaved.connect(updateData)
	if(error):
		print("Issue connecting to %s stateSaved signal" % activeSceneName)
		print(error)
	else:
		print("Connected to %s stateSaved signal" % activeSceneName)
	error = _activeSceneNode.sceneChanged.connect(changeScene)
	if (error):
		print("Issue connecting to %s sceneChanged signal" % activeSceneName)
		print(error)
	else:
		print("Connected to %s sceneChanged signal" % activeSceneName)
	
	
func updateData(data: OpenWorldData):
	_data = data
	print("updated data")
