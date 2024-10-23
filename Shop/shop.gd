extends Node2D
class_name Shop

var barScene: PackedScene
var cellScene: PackedScene
var player: Player
var currentBar: ShopBar

@export var xOffset : int = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	barScene = load("res://Shop/shop_bar.tscn")
	cellScene = load("res://Shop/shop_cell.tscn")
	player = self.find_parent("Space").find_child("PlayerShip")
	if player:
		player.expGained.connect(onExpGained)
		player.levelIncreased.connect(onLevelIncreased)
	else:
		push_warning("No player found, cannot listen for level increases!")
	var viewport = get_viewport_rect().size
	# this is the initial shop to get weapons, after we add a player
	self.launch()
	#self.attach_weapon_id_to_player(0)

func onExpGained(added: int, currentExp: int, maxExp: int):
	var viewport = get_viewport_rect().size
	var ratio = float(currentExp) / float(maxExp)
	self.getCurrentBar().setFillAmount(ratio)

func onLevelIncreased(newLevel: int):
	self.launch()

func getCurrentBar() -> ShopBar:
	if !self.currentBar:
		self.spawn()
	return self.currentBar

func spawn():
	# create a new shop bar
	var bar: ShopBar = barScene.instantiate()
	bar.name = "ShopBar" # for detection later
	self.currentBar = bar
	print("spawn: adding bar as child")
	self.add_child(bar)
	bar.cellScene = cellScene
	var viewport = get_viewport_rect().size
	bar.position = Vector2(viewport.x - self.xOffset, 0)
	bar.setFillAmount(0.0)
	
func launch():
	var bar: ShopBar = self.getCurrentBar()
	bar.launch()
	self.spawn() # prepare next bar

func ensureUpgrades():
	var candidates = self.get_children().filter(func (child):
		return is_instance_of(child, ShopBar) && (child as ShopBar).launched
	)
	if candidates.size() < 1:
		return
	candidates.sort_custom(func (a: ShopBar, b: ShopBar):
		return a.position.x < b.position.x
	)
	var bar = candidates[0]
	# if the first bar has offers, nothing to be done
	if bar.hasOffers:
		return
	# ask the player for possible upgrades
	# pick a few to show
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
	self.ensureUpgrades()

func onUpgradeSelected(upgrade: Upgrade):
	if player:
		player.applyUpgrade(upgrade)
