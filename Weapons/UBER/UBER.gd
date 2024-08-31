extends WeaponBase

@export var shotDelay : float = 1.0
@export var shotCooldown : float = 0.0
@export var damage : int = 1
@export var initialSpeed : float = 50.0
@export var accelerationX : float = 0.0
@export var accelerationY : float = 0.0
@export var bulletsPerBurst : int = 1.0
@export var burstDelay : float = 0.0
@export var spreadRandom : float = 1.0
@export var spreadFixed : float = 1.0
@export var waveAmplitude : float = 0
@export var waveType :int = 0
@export var phaseSpeed : float = 6
@export var phaseDirection : float = 1
@export var isHoming : bool = false
@export var isAutoaim : bool = false
@export var numberPenetrate : int = 0
@export var direction : float = 0
@export var weaponConfig : int = 1

var bullets_fired = 0
var firing_burst = false
# Reference to the Timer node
var timer
var currentWeaponConfig : int = 0
var bulletScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	super()  # Call the parent class's _ready() function
	bulletScene = load("res://Weapons/UBER/UBER_bullet.tscn")
	# Initialize the Timer node
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (weaponConfig != currentWeaponConfig):
		configWeapon()
	if (self.firing):
		shotCooldown -= delta
		if (shotCooldown <= 0.0):
			shotCooldown += shotDelay
			
			if (self.burstDelay == 0):
				for i in range(self.bulletsPerBurst):
					print(i)
					self.spawnBullet(i)
			else:
				self.startBurst()
			phaseDirection = -phaseDirection

func spawnBullet(index: int):
	var newBullet = bulletScene.instantiate()
	newBullet.position = self.global_position
	newBullet.speedX = self.initialSpeed
	newBullet.accelerationX = self.accelerationX
	newBullet.accelerationY = self.accelerationY
	
	if (bulletsPerBurst > 1):
		if (self.spreadRandom > 0):
			var random_angle = int(randf_range(-self.spreadRandom, self.spreadRandom))
			var newDirection = self.direction + random_angle
			newBullet.direction = newDirection
		elif (self.spreadFixed > 0):
			var newDirection = -self.spreadFixed + ( (self.spreadFixed * 2) / (self.bulletsPerBurst-1)) * index
			newBullet.direction = newDirection
	
	newBullet.waveAmplitude = self.waveAmplitude
	newBullet.phaseSpeed = self.phaseSpeed
	newBullet.setDirection(self.phaseDirection)
	newBullet.damage = self.damage
	
	self.find_parent("Space").add_child(newBullet)
	newBullet.connect("hit", Callable(self, "_on_bullet_hit"))
	
	playSound()

func startBurst():
	if not self.firing_burst:
		self.firing_burst = true
		self.bullets_fired = 0
		timer.wait_time = self.burstDelay
		timer.start()
		
func _on_timer_timeout():
	if self.bullets_fired < bulletsPerBurst:
		# Spawn a bullet
		self.spawnBullet(self.bullets_fired)
		self.bullets_fired += 1
		timer.start()  # Restart the timer for the next bullet
	else:
		# End of the burst
		self.firing_burst = false
		timer.wait_time = self.burstDelay
		timer.start()  # Start timer for the next burst
		
func configWeapon():
	currentWeaponConfig = weaponConfig
	if (weaponConfig == 1):
		self.shotDelay = 0.8
		self.initialSpeed = 600
		self.damage = 1
		self.accelerationX = 0
		self.bulletsPerBurst = 5
		self.burstDelay = 0
		self.spreadRandom = 0
		self.spreadFixed = 35
		self.waveAmplitude = 0
		self.phaseSpeed = 0
		self.isHoming = 0
		self.isAutoaim = 0
	elif (weaponConfig == 2):
		self.shotDelay = 1.2
		self.initialSpeed = 1000
		self.damage = 1
		self.accelerationX = -400
		self.bulletsPerBurst = 8
		self.burstDelay = 0
		self.spreadRandom = 4
		self.spreadFixed = 0
		self.waveAmplitude = 0
		self.phaseSpeed = 0
		self.isHoming = 0
		self.isAutoaim = 0
	elif (weaponConfig == 3):
		self.shotDelay = 0.5
		self.initialSpeed = 600
		self.damage = 1
		self.accelerationX = 0
		self.bulletsPerBurst = 2
		self.burstDelay = 0
		self.spreadRandom = 0
		self.spreadFixed = 90
		self.waveAmplitude = 0
		self.phaseSpeed = 0
		self.isHoming = 0
		self.isAutoaim = 0
	elif (weaponConfig == 4):
		self.shotDelay = 0.5
		self.initialSpeed = 700
		self.damage = 1
		self.accelerationX = 0
		self.bulletsPerBurst = 3
		self.burstDelay = 0.1
		self.spreadRandom = 0
		self.spreadFixed = 20
		self.waveAmplitude = 50
		self.phaseSpeed = 10
		self.isHoming = 0
		self.isAutoaim = 0
	elif (weaponConfig == 5):
		self.shotDelay = 2
		self.initialSpeed = 200
		self.damage = 8
		self.accelerationX = 800
		self.bulletsPerBurst = 1
		self.burstDelay = 0
		self.spreadRandom = 0
		self.spreadFixed = 0
		self.waveAmplitude = 0
		self.phaseSpeed = 0
		self.isHoming = 0
		self.isAutoaim = 0