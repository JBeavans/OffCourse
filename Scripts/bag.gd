extends StaticBody2D

signal bagInteractorEntered
signal bagInteractorExited

const CLUB_CAPACITY = 14
var clubs: Array[String] = ["empty", "empty", "empty", "default_3-iron",
 "default_4-iron", "default_5-iron", "default_6-iron", "default_7-iron",
 "default_8-iron", "default_9-iron", "empty", "empty", "empty", "empty"]
var selectedSlot: int = 3
var selectedClub: String = clubs[selectedSlot]


var bag_view_scene: PackedScene = load("res://Scenes/bag_view.tscn")
var viewingBag: bool = false
var bagState = {
	"clubs" : clubs,
	"selectedSlot" : selectedSlot,
	"selectedClub" : selectedClub
}

func setup(state: Dictionary):
	bagState = state
	clubs = state.clubs
	selectedSlot = state.selectedSlot
	selectedClub = state.selectedClub

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

func toggleSelectedLeft():
	#remove highlight from selected club before updating selection
	highlightSelectedClub(false)
	#update the selection so that it will loop from front to back
	if selectedSlot == 0:
		selectedSlot = CLUB_CAPACITY - 1
	else:
		selectedSlot -= 1
	
	selectedClub = clubs[selectedSlot]
	#turn highlight back on
	highlightSelectedClub(true)
	
func toggleSelectedRight():
	highlightSelectedClub(false)
	if selectedSlot == CLUB_CAPACITY - 1:
		selectedSlot = 0
	else:
		selectedSlot += 1
		
	selectedClub = clubs[selectedSlot]
	highlightSelectedClub(true)

func toggleBagView():
	if viewingBag:
		saveBagState()
		self.get_child(-1).queue_free()
		viewingBag = false
	else:
		var bagView = bag_view_scene.instantiate()
		bagView.position = Vector2(0, -75)
		var bagViewSprite: Node = bagView.get_child(0)
		var slots = bagViewSprite.get_children()
		var i = 0
		for slot in slots:
			if clubs[i] == "empty":
				slot.visible = false
			elif (ClubData.Clubs[clubs[i]].has("bagTextureSource")):
				slot.scale = Vector2(1.0 ,1.0)
				slot.texture = load(ClubData.Clubs[clubs[i]].bagTextureSource)
			i += 1
		add_child(bagView)
		viewingBag = true
		highlightSelectedClub(true)
	
func saveBagState():
	bagState.clubs = clubs
	bagState.selectedSlot = selectedSlot
	bagState.selectedClub = selectedClub

func getBagSlots() -> Array[Node]:
	var bagViewSprite = self.get_child(-1).get_child(0)
	var slots = bagViewSprite.get_children()
	return slots
	
func highlightSelectedClub(on: bool):
	if not selectedClub == null and not selectedClub == 'empty':
		if ClubData.Clubs[selectedClub].has("bagTextureSource"):
			var slots = getBagSlots()
			var slot = slots[selectedSlot]
			#probably should dynamically adjust the highlight sprite based on club type
			#this is currently breaking because there is no child of slot
			if on:
				slot.get_child(0).visible = true
				slot.position += Vector2(-5, -20) #may require future tweaks
				slot.scale = Vector2(1.4, 1.4)
			else:
				slot.get_child(0).visible = false
				slot.position += Vector2(5, 20)
				slot.scale = Vector2(1.0, 1.0)
				
func exchangeClub(clubName: String) -> String:
	#turn off club highlight during the swap
	highlightSelectedClub(false)
	#swap slot contents with whatever the player is holding
	#TODO: limit swap to only slot-specific items
	var slotContents = selectedClub
	selectedClub = clubName
	clubs[selectedSlot] = selectedClub
	saveBagState()
	#update slot icon
	var slot = getBagSlots()[selectedSlot]
	if clubName == "empty":
		slot.visible = false
	elif (ClubData.Clubs[clubName].has("bagTextureSource")):
		slot.scale = Vector2(1.0 ,1.0)
		slot.texture = load(ClubData.Clubs[clubName].bagTextureSource)
		slot.visible = true
	#turn club highlight back on
	highlightSelectedClub(true)
	return slotContents
