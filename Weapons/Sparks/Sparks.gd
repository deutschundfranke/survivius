extends WeaponBase

@export var shotDelay = 0.2
@export var shotCooldown = 0.0

var bulletScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	super()  # Call the parent class's _ready() function
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
			self.find_parent("Space").add_child(newBullet)
			
			
			playSound()
			
