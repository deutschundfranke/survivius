extends Node2D
class_name WeaponBase

var firing = false
@export var shotMinDamage : float = 5.0
@export var shotMaxDamage : float = 8.0
@export var sound : AudioStreamMP3
@export var hitsound : AudioStreamMP3
var soundplayer : AudioStreamPlayer
var hitplayer : AudioStreamPlayer
@export var label: String
var bulletScene: PackedScene
var upgradeLevels: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	soundplayer = AudioStreamPlayer.new()
	soundplayer.volume_db = -20
	add_child(soundplayer)
	hitplayer = AudioStreamPlayer.new()
	hitplayer.volume_db = -16
	add_child(hitplayer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# probably don't override, unless you have very specific needs,
# look at `configFromData` instead
func initFromData(data: Dictionary):
	self.name = data.get("name")
	self.label = data.get("label")
	self.bulletScene = load(data.bulletResource)
	self.configFromData(data.get("config"))
	self.upgradesFromData(data.get("upgrades"))

# this is the one to override
func configFromData(data: Dictionary):
	self.shotMinDamage = data.get("shotMinDamage")
	self.shotMaxDamage = data.get("shotMaxDamage")
	
func upgradesFromData(data: Array):
	for item : Dictionary in data:
		self.upgradeLevels[item.label] = item

func startFiring():
	firing = true
	
func stopFiring():
	firing = false

func playSound():
	# Check if the sound and soundplayer are set
	if sound and soundplayer:
		# Stop any currently playing sound
		soundplayer.stop()
		# Assign the sound to the player
		soundplayer.stream = sound
		# Play the sound from the beginning
		soundplayer.play()
	else:
		pass
		# print("Sound or SoundPlayer is not set.")
		
func playHit():
	# Check if the sound and soundplayer are set
	if hitsound and hitplayer:
		# Stop any currently playing sound
		hitplayer.stop()
		# Assign the sound to the player
		hitplayer.stream = hitsound
		# Play the sound from the beginning
		hitplayer.play()
	else:
		pass
		# print("Sound or SoundPlayer is not set.")
		

func _on_bullet_hit():
	self.playHit()

# close enough to normalized distribution
func getDamage() -> int:
	return int(round(randi_range(self.shotMinDamage * 10 - 5, self.shotMaxDamage * 10 + 4) / 10.0))

# should generally be overwritten
func getPossibleUpgrades() -> Array[Upgrade]:
	var upgrades : Array[Upgrade] = [];
	for key in self.upgradeLevels:
		var item : Dictionary = self.upgradeLevels[key]
		upgrades.push_back(
			Upgrade.new(
				"weapon", item.label, item.name + " " + self.name, Color.CYAN, self.label + "\n" + item.label, self.label
			)
		)
	return upgrades
	#return [
		#Upgrade.new(
		#	"weapon", "cooldown", "Cool Down " + self.name, Color.CYAN, self.label + "\n" + "CD", self.label
		#)
	#]

# should also be overwritten
func applyUpgrade(upgrade: Upgrade) -> void:
	var item : Dictionary = self.upgradeLevels[upgrade.feature]
	item['level'] = item['level'] + 1;
	for prop in item['properties']:
		self[prop['prop']] = prop['values'][item['level']]
	#if (upgrade.feature == "cooldown"):
	#	self.shotDelay *= 0.95
	#else:
#		push_warning("Unknown upgrade feature ", upgrade.feature)
