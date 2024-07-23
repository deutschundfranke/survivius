extends WeaponBase

@export var shotDelay = 1.0
@export var shotCooldown = 0.0

var bulletScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	super()  # Call the parent class's _ready() function
	bulletScene = load("res://Weapons/Blaster/blaster_bullet.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (self.firing):
		shotCooldown -= delta
		if (shotCooldown <= 0.0):
			shotCooldown += shotDelay
			# shoot!
			print('Shoot!')
			var newBullet = bulletScene.instantiate()
			newBullet.position = self.global_position
			self.find_parent("Space").add_child(newBullet)
			
			playSound()
			
