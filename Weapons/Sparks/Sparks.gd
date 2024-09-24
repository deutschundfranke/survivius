extends WeaponBase

@export var shotDelay = 0.2
@export var shotCooldown = 0.0
@export var shotSpeed = 200
@export var shotMaxDistance = 200

var bulletScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	super()  # Call the parent class's _ready() function
	self.shotMinDamage = 2.0
	self.shotMaxDamage = 3.5
	bulletScene = load("res://Weapons/Sparks/sparks_bullet.tscn")

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
			var direction = (PI * 2) * randf()
			newBullet.setDirection(direction)
			newBullet.speed = self.shotSpeed
			newBullet.maxDistance = self.shotMaxDistance
			self.find_parent("Space").add_child(newBullet)
			newBullet.connect("hit", Callable(self, "_on_bullet_hit"))
			
			playSound()
			
func getPossibleUpgrades() -> Array[Upgrade]:
	var list: Array[Upgrade] = []
	if (self.shotMaxDistance < 500):
		list.append(Upgrade.new(
			"weapon", "distance", "Shot Distance " + self.name, Color.DARK_BLUE, self.label + "\n" + "MD", self.label
		))
	if (self.shotSpeed < 500):
		list.append(Upgrade.new(
			"weapon", "shot_speed", "Shot Speed " + self.name, Color.ORANGE, self.label + "\n" + "SP", self.label
		))
	return list

func applyUpgrade(upgrade: Upgrade) -> void:
	if (upgrade.feature == "distance"):
		self.shotMaxDistance += 20
	elif (upgrade.feature == "shot_speed"):
		self.shotSpeed += 50
	else:
		push_warning("Unknown upgrade feature ", upgrade.feature)
