extends WeaponBase

@export var shotDelay = 1.0
@export var shotCooldown = 0.0
@export var shotSpeed = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	super()  # Call the parent class's _ready() function
	self.shotMinDamage = 5.0
	self.shotMaxDamage = 8.0
	bulletScene = load("res://Weapons/Blaster/blaster_bullet.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (self.firing):
		shotCooldown -= delta
		if (shotCooldown <= 0.0):
			shotCooldown += shotDelay
			# shoot!
			# print('Shoot!')
			var damage : int = self.getDamage()
			var newBullet = bulletScene.instantiate()
			newBullet.speed = self.shotSpeed
			newBullet.position = self.global_position
			newBullet.damage = damage
			self.find_parent("Space").add_child(newBullet)
			newBullet.connect("hit", Callable(self, "_on_bullet_hit"))
			
			playSound()
			
	# Perform actions like damage calculations, play sound effects, etc.

func getPossibleUpgrades() -> Array[Upgrade]:
	var list: Array[Upgrade] = []
	if (self.shotDelay > 0.05):
		list.append(Upgrade.new(
			"weapon", "cooldown", "Cool Down " + self.name, Color.CYAN, self.label + "\n" + "CD", self.label
		))
	if (self.shotSpeed < 1000):
		list.append(Upgrade.new(
			"weapon", "shot_speed", "Shot Speed " + self.name, Color.ORANGE, self.label + "\n" + "SP", self.label
		))
	return list

func applyUpgrade(upgrade: Upgrade) -> void:
	if (upgrade.feature == "cooldown"):
		self.shotDelay *= 0.8
	elif (upgrade.feature == "shot_speed"):
		self.shotSpeed += 100
	else:
		push_warning("Unknown upgrade feature ", upgrade.feature)
