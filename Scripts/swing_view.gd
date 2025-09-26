extends ManagedScene

#signal stateSaved
#signal sceneChanged

var openWorldScene: String = "res://Scenes/openWorld.tscn"

#var _data: OpenWorldData
@onready var ball: RigidBody2D = $ball

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for now we'll just remove the ball. Once there are more types, we'll instantiate the active ball's corresponding swing-view sprite (likely using an enum w/ a dict)
	if _data.activeBallID == 0:
		ball.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("look_down", false):
		var nextScene: PackedScene = load(openWorldScene)
		#signal exit to SceneManager
		stateSaved.emit(_data)
		sceneChanged.emit(nextScene)
		print("attempted to return to Open World")
		#openWorldScene.importData(_data)
		#get_tree().change_scene_to_packed(openWorldScene)
		
 
#func importData(data: OpenWorldData) -> void:
	#_data = data
	#print("%s imported data", self.name)


func _on_club_ball_struck(launchConditions: Vector2) -> void:
	var launchVel = launchConditions.x
	#calculate openWorld ball velocity
	#add variables to change velocity and rotation based on ballType
	var ballVelocity: Vector2 = abs(launchVel) * _data.playerData.dir.orthogonal()
	var activeBall = _data.activeBallID
	#set dictionary data for ball velocity... which is actually just the balls projected landing point
	print("active ball: " + str(_data.activeBallID ))
	_data.ballsDict[activeBall].dir2D = ballVelocity + _data.ballsDict[activeBall].pos
	_data.ballsDict[activeBall].launchConditions = launchConditions
	var i:= 0
	for ball in _data.balls:
		if ball.ballID == activeBall:
			#set array data for ball velocity (actually just the projected landing point)
			_data.balls[i].dir2D = ballVelocity + _data.balls[i].pos #there has to be a better way
			_data.balls[i].launchConditions = launchConditions
			#set active ball back to 0 before returning (this will make it easier to check if another player is swinging
			_data.activeBallID = 0
			return
		i += 1
	
	#dictionary method
	#_data.ballsDict[_data.activeBallID].vel = ballVelocity
