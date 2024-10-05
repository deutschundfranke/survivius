extends Node2D
class_name Shop

var barScene: PackedScene
var cellScene: PackedScene
var player: Player
var weapon_data : Array

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
	self.weapon_data = self.load_json_from_resource("res://data/weapons.json")
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
	bar.position = Vector2(viewport.x, 0)
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
		
# Jonny Code for weapons JSON
func load_json_from_resource(json_path: String) -> Array:
	var file := FileAccess.open(json_path, FileAccess.READ)
	
	if file == null:
		print("Failed to open file: ", json_path)
		return []
	
	# Read the contents of the file as a string
	var json_string := file.get_as_text()
	file.close()

	# Parse the JSON string
	var json = JSON.new();
	var json_result = json.parse(json_string)

	# Check for errors
	if json_result != OK:
		print("Error parsing JSON: ", json.get_error_message)
		return []

	# Return the parsed JSON (assuming it's an array)
	return json.get_data()

func attach_weapon_to_player(label : String):
	for item : Dictionary in self.weapon_data:
		if (item.get("label") == label):
			self.attach_weapon_data_to_player(item)

func attach_weapon_data_to_player(weaponData : Dictionary):
	var weaponScene : PackedScene = load(weaponData.get("resource"))
	# should be dynamic Class type?
	var weapon : UBER = weaponScene.instantiate()
	
	weapon.shotDelay = weaponData.get("shotDelay")
	weapon.initialSpeed = weaponData.get("initialSpeed")
	weapon.shotMinDamage = weaponData.get("shotMinDamage")
	weapon.shotMaxDamage = weaponData.get("shotMaxDamage")
	weapon.accelerationX = weaponData.get("accelerationX")
	weapon.accelerationY = weaponData.get("accelerationY")
	weapon.bulletsPerBurst = weaponData.get("bulletsPerBurst")
	weapon.burstDelay = weaponData.get("burstDelay")
	weapon.spreadRandom = weaponData.get("spreadRandom")
	weapon.spreadFixed = weaponData.get("spreadFixed")
	weapon.waveAmplitude = weaponData.get("waveAmplitude")
	weapon.phaseSpeed = weaponData.get("phaseSpeed")
	weapon.isHoming = weaponData.get("isHoming")
	weapon.isAutoaim = weaponData.get("isAutoaim")
	weapon.isCenteraim = weaponData.get("isCenteraim")
	weapon.isBeam = weaponData.get("isBeam")
	weapon.autoaimSpeed = weaponData.get("autoaimSpeed")
	weapon.homingTurnSpeed = weaponData.get("homingTurnSpeed")
	weapon.duration = weaponData.get("duration")
	
	weapon.startFiring()
	player.add_child(weapon)
	player.weapons.push_back(weapon)
