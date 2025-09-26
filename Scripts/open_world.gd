extends ManagedScene

var ball_scene: PackedScene = load("res://Scenes/ball.tscn")
var player_scene: PackedScene = load("res://Scenes/player.tscn")
var swing_scene: PackedScene = load("res://Scenes/swingView.tscn")
var flight_path_scene: PackedScene = load("res://Scenes/flightPath.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not _data == null:
		_populateScene()
	else:
		_data = OpenWorldData.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#creates a ball at the given position with optional velocity
func spawn_ball(pos: Vector2, vel: Vector2 = Vector2.ZERO, id: int = 0) -> void:
	print("spawn_ball signal received")
	var ball = ball_scene.instantiate()
	ball.position = pos
	ball.velocity = vel
	#check if this is a new ball (does not have an ID yet)
	if id == 0:
		#assign an ID based on how many balls already exist
		if not _data.balls.is_empty():
			ball.id = _data.balls[-1].ballID + 1
		else:
			ball.id = 1 #hopefully this is the only edge case XD
		#create a new ball data object
		var newBallData = BallData.new()
		newBallData.ballID = ball.id
		newBallData.pos = pos
		newBallData.dir2D = vel
		#add the ballData to the list of known balls
		_data.balls.append(newBallData)
		_data.ballsDict[ball.id] = newBallData
		_data.playerData.balls.append(ball.id)
	else:
		ball.id = id
	add_child(ball)
	ball.ballMoved.connect(_on_ballMoved.bind(ball.id))
	ball.ballStopped.connect(_on_ballStopped)

#further define logic in an on_ball_picked(id: int) method that does logic and/or waits for further input from player before calling remove_ball	
func remove_ball(id: int) -> void:
	var balls = get_tree().get_nodes_in_group("balls")
	#iterate through array and remove ball with matching id (optimize later)
	var i:int = 0
	for ball in balls:
		if ball.id == id:
			ball.queue_free()
			_data.balls.remove_at(i) #may be more optimal to set _data.balls = get_tree().get_nodes_in_group("balls")
			_data.ballsDict.erase(id) #may be more optimal to set _data.balls = get_tree().get_nodes_in_group("balls")
			_data.playerData.balls.erase(id)
			print("\nremoved ball #" + str(id))
			printBalls()
			printPlayersBalls()
			print()
			return
		i += 1
			
	print("could not find ball " + str(id))


func load_balls(ballsInPlay: Array) -> void:
	for ball in ballsInPlay:
		spawn_ball(ball.pos, ball.dir2D, ball.ballID)
	printBalls()
	printPlayersBalls()
	

#loads the player given a position and direction
func spawn_player(pos: Vector2, dir: Vector2) -> void:
	var player = player_scene.instantiate()
	player.position = pos
	player.idleDirection = dir
	add_child(player)
	print("player spawned")
	
func load_players(playersInScene: Array[PlayerData]) -> void:
	for player in playersInScene:
		spawn_player(player.pos, player.dir)


func _populateScene() -> void:
	if not _data.balls == null:
		load_balls(_data.balls)
	if not _data.playerData == null:
		#update to load_players if tracking more than one player
		#spawn_player(_data.playerData.pos, _data.playerData.dir)
		$Player.position = _data.playerData.pos
		$Player.setDirection(_data.playerData.dir)
		$Player.setBallCount(_data.playerData.balls.size())
	else:
		print("No Player Data!")


func _on_player_swing_triggered(id: int) -> void:
	_data.playerData.pos = $Player.position
	_data.playerData.dir = $Player.idleDirection
	_data.activeBallID = id
	print("Player at: " + str(_data.playerData.pos) + " facing: " + str(_data.playerData.dir) + " activeBall:" + str(_data.activeBallID))
	stateSaved.emit(_data)
	sceneChanged.emit(swing_scene)


func printPlayersBalls() -> void:
	print("\nplayer balls:\n")
	for id in _data.playerData.balls:
		print("\t" + str(id))
	print("\n")

func printBalls() -> void:
	print("\nballs in play:\n")
	for ball in _data.balls:
		print("\t" + str(ball.ballID) + "\tpos: " + str(ball.pos))
	print("\n")
	#dictionary method
	print("\nballsDict:\n")
	for id in _data.ballsDict:
		var ballData = _data.ballsDict[id]
		print("\t" + str(id) + "\tpos: " + str(ballData.pos) + "\tdir2d: " + str(ballData.dir2D) + "\tlaunchVars: " + str(ballData.launchConditions))
	print()

func _on_ballMoved(pos: Vector2, dir: Vector2, id: int) -> void:
	var i := 0
	for ball in _data.balls:
		if ball.ballID == id:
			_data.balls[i].pos = pos
			_data.balls[i].dir2D = dir
		i += 1
	#dictionary method (possibly... may need to create a BalLData var and pass it back)
	_data.ballsDict[id].pos = pos
	_data.ballsDict[id].dir2D = dir
	
	if _data.ballsDict[id].launchConditions:
		#var ballData = _data.ballsDict[id]
		#var launchV = ballData.laun
		var flight_path = flight_path_scene.instantiate()
		flight_path.setup(_data.ballsDict[id].launchConditions)
		#reset launch conditions of given ball to zero so the node is only added once
		_data.ballsDict[id].launchConditions = Vector2.ZERO
		_data.ballsDict[id].flightPath = flight_path
		var flight_time = flight_path.getFlightTime()
		print("flight time: " + str(flight_time))
		$Player.add_child(flight_path)
		
	
func _on_ballStopped() -> void:
	$Player.get_child(-1).queue_free()
