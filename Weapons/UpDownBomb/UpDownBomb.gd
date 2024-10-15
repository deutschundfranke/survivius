extends WeaponBase

@export var shotDelay = 0.4
@export var shotCooldown = 0.0
var nextDirection = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	super()  # Call the parent class's _ready() function
	self.shotMinDamage = 10.0
	self.shotMaxDamage = 20.0
	bulletScene = load("res://Weapons/UpDownBomb/updownbomb_bullet.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (self.firing):
		shotCooldown -= delta
		if (shotCooldown <= 0.0):
			shotCooldown += shotDelay
			# shoot!
			# print('da Bomb!')
			var newBullet = bulletScene.instantiate()
			newBullet.position = self.global_position
			newBullet.setDirection(nextDirection)
			self.find_parent("Space").add_child(newBullet)
			nextDirection *= -1
			newBullet.connect("hit", Callable(self, "_on_bullet_hit"))
			
			playSound()
			
