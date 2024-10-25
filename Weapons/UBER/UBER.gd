extends WeaponBase
class_name UBER

@export var shotDelay : float = 1.0
@export var shotCooldown : float = 0.0
@export var damage : int = 1
@export var initialSpeed : float = 50.0
@export var initialSpeedRandom : float = 0.0
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
@export var autoaimSpeed : float = 30
var autoaimDirection : float = 0;
var autoaimTarget : float = 0;
@export var homingTurnSpeed : float = 0
@export var isCenteraim : bool = false
@export var isBeam : bool = false
@export var duration : float = 15
@export var numberPenetrate : int = 1
@export var areaOfEffect : float = 0.0
@export var direction : float = 0
var spawnsChildren : bool = true

var bullets_fired = 0
var firing_burst = false
# Reference to the Timer node
var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	super()  # Call the parent class's _ready() function
	
	# Initialize the Timer node
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (self.firing):
		shotCooldown -= delta
		if (shotCooldown <= 0.0):
			shotCooldown += shotDelay
			
			if (self.burstDelay == 0):
				for i in range(self.bulletsPerBurst):
					#print(i)
					self.spawnBullet(i)
			else:
				self.startBurst()
			
		if (self.isAutoaim):
			rotate_turret_towards_target(delta)

func configFromData(data: Dictionary):
	self.shotDelay = data.get("shotDelay")
	self.initialSpeed = data.get("initialSpeed")
	self.initialSpeedRandom = data.get("initialSpeedRandom")
	self.shotMinDamage = data.get("shotMinDamage")
	self.shotMaxDamage = data.get("shotMaxDamage")
	self.accelerationX = data.get("accelerationX")
	self.accelerationY = data.get("accelerationY")
	self.bulletsPerBurst = data.get("bulletsPerBurst")
	self.burstDelay = data.get("burstDelay")
	self.spreadRandom = data.get("spreadRandom")
	self.spreadFixed = data.get("spreadFixed")
	self.waveAmplitude = data.get("waveAmplitude")
	self.phaseSpeed = data.get("phaseSpeed")
	self.isHoming = data.get("isHoming")
	self.isAutoaim = data.get("isAutoaim")
	self.isCenteraim = data.get("isCenteraim")
	self.isBeam = data.get("isBeam")
	self.autoaimSpeed = data.get("autoaimSpeed")
	self.homingTurnSpeed = data.get("homingTurnSpeed")
	self.duration = data.get("duration")
	self.numberPenetrate = data.get("numberPenetrate")
	self.areaOfEffect = data.get("areaOfEffect")
	
	if (self.isAutoaim):
		$AutoTarget.visible = true

func spawnBullet(index: int):
	var newBullet = bulletScene.instantiate()
	newBullet.position = self.global_position
	newBullet.speedX = self.initialSpeed + randi_range(-self.initialSpeedRandom,self.initialSpeedRandom)
	newBullet.accelerationX = self.accelerationX
	newBullet.accelerationY = self.accelerationY
	
	if (self.isAutoaim):
		self.direction = self.autoaimDirection
		
	if (self.isCenteraim):
		var viewport_rect = get_viewport().get_visible_rect().size
		var center : Vector2 = Vector2(viewport_rect.x / 2,viewport_rect.y / 2)
		self.direction = calculate_angle_between_positions(self.global_position, center)
		
	newBullet.direction = self.direction
	
	if (self.isHoming):
		newBullet.isHoming = self.isHoming
		newBullet.homingTurnSpeed = self.homingTurnSpeed
		var localTarget : EnemyBase = self.getNearestEnemy();
		# initial rotation?
		if (localTarget):
			pass
			# newBullet.direction = calculate_angle_between_positions(self.global_position, localTarget.global_position)
	
	
	if (bulletsPerBurst > 1):
		var newDirection = self.direction
		# first fixed spread
		if (self.spreadFixed > 0):
			newDirection = self.direction - self.spreadFixed + ( (self.spreadFixed * 2) / (self.bulletsPerBurst-1)) * index
		# then add random
		if (self.spreadRandom > 0):
			var random_angle = int(randf_range(-self.spreadRandom, self.spreadRandom))
			newDirection += random_angle
		newBullet.direction = newDirection
	
	self.phaseDirection = -self.phaseDirection
	newBullet.waveAmplitude = self.waveAmplitude
	newBullet.phaseSpeed = self.phaseSpeed
	newBullet.setDirection(self.phaseDirection)
	newBullet.damage = self.getDamage()
	newBullet.duration = self.duration
	newBullet.isBeam = self.isBeam
	newBullet.numberPenetrate = self.numberPenetrate
	newBullet.areaOfEffect = self.areaOfEffect
	
	self.find_parent("Space").add_child(newBullet)
	newBullet.connect("hit", Callable(self, "_on_bullet_hit"))
	newBullet.connect("die_signal", Callable(self, "_on_bullet_die"))
	
	playSound()

func spawnChildBullet(bullet:BulletBase, index:int):
	var newBullet = bulletScene.instantiate()
	newBullet.position = bullet.global_position
	newBullet.speedX = 500
	newBullet.accelerationX = self.accelerationX
	newBullet.accelerationY = self.accelerationY
	
	newBullet.direction = index * 60
	
	var angle_radians = deg_to_rad(newBullet.direction)
	var forward_velocity = Vector2(cos(angle_radians) * 50, sin(angle_radians) * 50)
	newBullet.position += forward_velocity
	newBullet.spawnsChildren = false
	newBullet.damage = self.getDamage()
	
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
		
func getNearestEnemy() -> EnemyBase:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var target:EnemyBase= null
	var targetdistance : float = 9999999
	for enemy:EnemyBase in enemies:
		var distance = self.global_position.distance_squared_to(enemy.global_position)
		if (distance < targetdistance):
			target = enemy
			targetdistance = distance
	return target
		
func calculate_angle_between_positions(A: Vector2, B: Vector2) -> float:
	# Calculate the direction vector from A to B
	var direction = B - A

	# Calculate the angle in radians using atan2
	var angle_radians = atan2(direction.y, direction.x)

	# Convert the angle from radians to degrees
	var angle_degrees = rad_to_deg(angle_radians)

	return angle_degrees

func rotate_turret_towards_target(delta: float) -> void:
	
	var target = self.getNearestEnemy()
	
	var angle : float;
	if (target):
		var targetPoint = target.global_position;
		# movement prediction
		var distance = self.global_position.distance_to(targetPoint)
		# how long to get there
		var duration = distance / self.initialSpeed; 
		targetPoint = targetPoint + target.movement * duration;
		
		angle = self.calculate_angle_between_positions(self.global_position, targetPoint)
		self.autoaimTarget = angle
	else:
		self.autoaimTarget = 0
	
	# Calculate the difference between the target angle and the current angle
	var angle_difference: float = self.autoaimTarget - self.autoaimDirection
	
	# Normalize the angle to be within the range of -180 to 180 degrees
	angle_difference = fmod(angle_difference + 180, 360) - 180

	# Calculate the maximum rotation step we can take this frame
	var rotation_step: float = autoaimSpeed * delta

	# Determine the direction and rotate towards the target angle
	if abs(angle_difference) <= rotation_step:
		# If the difference is small enough, snap to the target angle
		self.autoaimDirection = self.autoaimTarget
	else:
		# Rotate in the shortest direction towards the target
		self.autoaimDirection += sign(angle_difference) * rotation_step
	
	$AutoTarget.rotation_degrees = self.autoaimDirection
		
func _on_bullet_die(bullet:BulletBase):
	"""if (self.spawnsChildren):
		for i in range(6):
			self.spawnChildBullet(bullet, i)
	print("DIE")"""
