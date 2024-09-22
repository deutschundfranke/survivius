extends WeaponBase

@export var shotDelay = 0.85
@export var shotCooldown = 0.0
@export var shotSpeed = 200
@export var shotMaxAmplitude = 100
@export var shotPhasespeed = 6
var nextDirection = 1;

var bulletScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	super()  # Call the parent class's _ready() function
	bulletScene = load("res://Weapons/Waver/waver_bullet.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (self.firing):
		shotCooldown -= delta
		if (shotCooldown <= 0.0):
			shotCooldown += shotDelay
			# shoot!
			# print('do the wave!')
			var newBullet = bulletScene.instantiate()
			newBullet.position = self.global_position
			newBullet.setDirection(nextDirection)
			newBullet.speed = self.shotSpeed
			newBullet.maxAmplitude = self.shotMaxAmplitude
			newBullet.phasespeed = self.shotPhasespeed
			self.find_parent("Space").add_child(newBullet)
			nextDirection *= -1
			newBullet.connect("hit", Callable(self, "_on_bullet_hit"))
			
			playSound()
			
func getPossibleUpgrades() -> Array[Upgrade]:
	var list: Array[Upgrade] = []
	if (self.shotMaxAmplitude < 400):
		list.append(Upgrade.new(
			"weapon", "amplitude", "Shot Amplitude " + self.name, Color.DARK_MAGENTA, self.label + "\n" + "AM", self.label
		))
	if (self.shotSpeed < 500):
		list.append(Upgrade.new(
			"weapon", "shot_speed", "Shot Speed " + self.name, Color.ORANGE, self.label + "\n" + "SP", self.label
		))
	if (self.shotPhasespeed < 12):
		list.append(Upgrade.new(
			"weapon", "frequency", "Shot Frequency " + self.name, Color.PALE_VIOLET_RED, self.label + "\n" + "FQ", self.label
		))
	return list

func applyUpgrade(upgrade: Upgrade) -> void:
	if (upgrade.feature == "amplitude"):
		self.shotMaxAmplitude += 20
	elif (upgrade.feature == "shot_speed"):
		self.shotSpeed += 50
	elif (upgrade.feature == "frequency"):
		self.shotPhasespeed += 0.5
	else:
		push_warning("Unknown upgrade feature ", upgrade.feature)
