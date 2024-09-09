extends Node2D
class_name Shop

var barScene: PackedScene
var cellScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	barScene = load("res://Shop/shop_bar.tscn")
	cellScene = load("res://Shop/shop_cell.tscn")
	#self.spawn()
	var player: Player = self.find_parent("Space").find_child("PlayerShip")
	if player:
		player.levelIncreased.connect(onLevelIncreased)
	else:
		push_warning("No player found, cannot listen for level increases!")

func onLevelIncreased(newLevel: int):
	self.spawn()

func spawn():
	# check the player (and thereby their weapons) for possible updates
	# pick the number N of updates available
	# pick those updates from the list
	# spawn, scale and spread out cells
	
	# most of this should be moved to the bar itself
	# just give it a list of updates to offer
	var bar: ShopBar = barScene.instantiate()
	self.add_child(bar)
	bar.cellScene = cellScene
	var viewport = get_viewport_rect().size
	bar.position = Vector2(viewport.x, 0)
	var updates = [null, null, null]
	bar.createOffers(updates)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func onCellCollected(cell: ShopCell):
	var bar: ShopBar = cell.get_parent()
	if bar:
		bar.queue_free()
	# add update functionality here
