extends Node2D
class_name ShopBar

var cellScene: PackedScene
var collected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func createOffers(updates):
	var viewport = get_viewport_rect().size
	var cellNumber = updates.size()
	var cellHeight = viewport.y / float(cellNumber)
	for n in cellNumber:
		var cell: ShopCell = cellScene.instantiate()
		$Cells.add_child(cell)
		cell.setHeight(cellHeight)
		cell.position = Vector2(0, (n + 0.5) * cellHeight)
		cell.collected.connect(onCellCollected)
		cell.offerID = n


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.x = self.position.x -60 * delta
	if self.global_position.x < -200:
		# this should never happen once collection is mandatory, but we should be prepared
		self.queue_free()

func onCellCollected(cell: ShopCell):
	# guard against multiple collections + pickups in this frame – we queue the cells
	# to be freed on the next frame, collisions could still happen
	if self.collected:
		return
	self.collected = true
	for child in $Cells.get_children():
		child.queue_free()
		
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		var playership : Node2D = players[0]
		playership.levelUpThis(cell.offerID)
