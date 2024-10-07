extends Node
class_name Armory

@export var weapons: Array[WeaponBase] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if self.weapons.size() == 0:
		var weapon_data = self.load_json_from_resource("res://Data/weapons.json")
		for item : Dictionary in weapon_data:
			var weapon = self.weapon_from_data(item)
			self.weapons.push_back(weapon)

func pickRandomWeapon() -> WeaponBase:
	if self.weapons.size() == 0:
		return null
	return self.weapons.pick_random()

func findWeaponByLabel(label: String) -> WeaponBase:
	var matchingWeapons = self.weapons.filter(
		func(weapon: WeaponBase): return weapon.label == label
	)
	if matchingWeapons.size() == 0:
		return null
	return matchingWeapons[0]

func removeWeapon(weapon: WeaponBase):
	self.weapons = self.weapons.filter(
		func(other: WeaponBase): return other.label != weapon.label
	)

func weapon_from_data(weaponData : Dictionary) -> WeaponBase:
	var weaponScene : PackedScene = load(weaponData.get("resource"))
	# should be dynamic Class type?
	var weapon : UBER = weaponScene.instantiate()
	
	weapon.name = weaponData.get("name")
	weapon.label = weaponData.get("label")
	
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
	
	return weapon
	
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
