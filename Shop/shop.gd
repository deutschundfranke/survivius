extends Node2D
class_name Shop

var barScene: PackedScene
var cellScene: PackedScene
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	barScene = load("res://Shop/shop_bar.tscn")
	cellScene = load("res://Shop/shop_cell.tscn")
	#self.spawn()
	player = self.find_parent("Space").find_child("PlayerShip")
	if player:
		player.levelIncreased.connect(onLevelIncreased)
	else:
		push_warning("No player found, cannot listen for level increases!")

func onLevelIncreased(newLevel: int):
	self.spawn()

func spawn():
	# check the player (and thereby their weapons) for possible upgrades
	# pick the number N of upgrades available
	# pick those upgrades from the list
	# spawn, scale and spread out cells
	
	# most of this should be moved to the bar itself
	# just give it a list of upgrades to offer
	var bar: ShopBar = barScene.instantiate()
	self.add_child(bar)
	bar.cellScene = cellScene
	var viewport = get_viewport_rect().size
	bar.position = Vector2(viewport.x, 0)
	var upgrades = [
		Upgrade.new(
			"ship", "new_weapon", "New weapon", Color.RED
		),
		Upgrade.new(
			"ship", "speed", "Speed up!", Color.YELLOW
		),
		Upgrade.new(
			"all_weapons", "improve_cooldown", "Cool down!", Color.CYAN 
		)
	]
	bar.createOffers(upgrades)
	bar.upgradeSelected.connect(onUpgradeSelected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func onUpgradeSelected(upgrade: Upgrade):
	if player:
		player.applyUpgrade(upgrade)
