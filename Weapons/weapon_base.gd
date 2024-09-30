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
	return [
		Upgrade.new(
			"weapon", "cooldown", "Cool Down " + self.name, Color.CYAN, self.label + "\n" + "CD", self.label
		)
	]

# should also be overwritten
func applyUpgrade(upgrade: Upgrade) -> void:
	if (upgrade.feature == "cooldown"):
		self.shotDelay *= 0.95
	else:
		push_warning("Unknown upgrade feature ", upgrade.feature)
