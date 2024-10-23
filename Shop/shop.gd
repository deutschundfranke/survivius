extends Node2D
class_name Shop

var barScene: PackedScene
var cellScene: PackedScene
var player: Player
var startingX : int = 1400

# Called when the node enters the scene tree for the first time.
func _ready():
	barScene = load("res://Shop/shop_bar.tscn")
	cellScene = load("res://Shop/shop_cell.tscn")
	player = self.find_parent("Space").find_child("PlayerShip")
	if player:
		player.levelIncreased.connect(onLevelIncreased)
	else:
		push_warning("No player found, cannot listen for level increases!")
	# this is the initial shop to get weapons, after we add a player
	self.spawn()
	#self.attach_weapon_id_to_player(0)

func onLevelIncreased(newLevel: int):
	self.spawn()

func spawn():
	# create a new shop bar
	# ask the player for possible upgrades
	# pick a few to show
	var bar: ShopBar = barScene.instantiate()
	self.add_child(bar)
	bar.cellScene = cellScene
	var viewport = get_viewport_rect().size
	bar.position = Vector2(self.startingX, 0)
	self.startingX = viewport.x
	var upgrades = [
		Upgrade.new("none", "none", "No Upgrade for you!", Color.BLACK, "X")
	]
	if (player):
		upgrades = player.getPossibleUpgrades()
	upgrades.shuffle()
	upgrades = upgrades.slice(0, 4)
	bar.createOffers(upgrades)
	bar.upgradeSelected.connect(onUpgradeSelected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func onUpgradeSelected(upgrade: Upgrade):
	if player:
		player.applyUpgrade(upgrade)
