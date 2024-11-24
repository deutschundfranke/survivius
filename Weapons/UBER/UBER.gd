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
var deathScene: PackedScene
var upgradeLevels: Dictionary = {}

@export var shotDelay : float = 1.0
@export var shotCooldown : float = 0.0
@export var initialSpeed : float = 50.0
@export var initialSpeedRandom : float = 0.0
@export var accelerationX : float = 0.0
@export var accelerationY : float = 0.0
@export var knockbackStrength : int = 400
@export var bulletsPerBurst : int = 1.0
@export var burstDelay : float = 0.0
@export var burstType : int = 0
@export var burstSide : int = 1
@export var perBurstDirection : int = 0
@export var perBulletDirection : int = 0
@export var spreadRandom : float = 1.0
@export var spreadFixed : float = 1.0
@export var waveAmplitude : float = 0
@export var waveType :int = 0
@export var phaseSpeed : float = 6
@export var phaseDirection : float = 1
@export var isHoming : bool = false
@export var isAutoaim : bool = false
@export var autoaimSpeed : float = 30
@export var prediction : float = 0.0
var autoaimDirection : float = 0;
var autoaimTarget : float = 0;
@export var homingTurnSpeed : float = 0
@export var isCenteraim : bool = false
@export var isBeam : bool = false
@export var beamWidth : float = 0
@export var beamInterval : float = 0
@export var isShield : bool = false
@export var duration : float = 15
@export var maxDistance : int = 0
@export var numberPenetrate : int = 1
@export var areaOfEffect : float = 0.0
@export var direction : float = 0
@export var startSize : float = 0
@export var endSize : float = 0
@export var radialRadius : float = 0
@export var radialSpeed : float = 0
@export var aoeOnDeath : int = 0
@export var spawnChildrenOnDeath : int = 0

# children config
@export var maxGenerations : int = 0
@export var generationBullets : Array = [] # how many bullets in which generation
@export var childrenSpreadFixed : float = 30
@export var childrenSpreadRandom : float = 0
@export var childrenDirection : float = 0
@export var childrenAutoAim : bool = false
@export var childrenInstant : bool = false
@export var childrenAreaOfEffect : float = 0.0
@export var childrenAoeOnDeath : int = 0
@export var childMinDamage : float = 1
@export var childMaxDamage : float = 1
@export var childInitialSpeed : float = 0
@export var childAccelerationX : float = 0
@export var childIsHoming : bool = false
@export var childHomingSpeed : float = 0
@export var childDuration : float = 15
@export var childMaxDistance : float = 0

# Reference to the DPSMeter node
@onready var dps_meter = $DPSMeter  # Assuming DPSMeter is a child node

var bullets_fired = 0
var firing_burst = false
# Reference to the Timer node
var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	soundplayer = AudioStreamPlayer.new()
	soundplayer.volume_db = -20
	add_child(soundplayer)
	hitplayer = AudioStreamPlayer.new()
	hitplayer.volume_db = -16
	add_child(hitplayer)
	
	# Initialize the Timer node
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (self.firing):
		if (self.burstDelay == 0 || not self.firing_burst):
			shotCooldown -= delta
		if (shotCooldown <= 0.0):
			
			if (self.burstDelay == 0):
				for i in range(self.bulletsPerBurst):
					self.spawnBullet(i)
				shotCooldown += shotDelay
				self._on_burst_end()
			else:
				self.startBurst()
			
		if (self.isAutoaim):
			rotate_turret_towards_target(delta)
			
# probably don't override, unless you have very specific needs,
# look at `configFromData` instead
func initFromData(data: Dictionary):
	self.name = data.get("name")
	self.label = data.get("label")
	self.bulletScene = load(data.bulletResource)
	if (data.has("deathResource")): self.deathScene = load(data.deathResource)
	self.configFromData(data.get("config"))
	self.upgradesFromData(data.get("upgrades"))
	
func configFromData(data: Dictionary):
	self.shotDelay = data.get("shotDelay")
	self.initialSpeed = data.get("initialSpeed")
	self.initialSpeedRandom = data.get("initialSpeedRandom")
	self.shotMinDamage = data.get("shotMinDamage")
	self.shotMaxDamage = data.get("shotMaxDamage")
	self.accelerationX = data.get("accelerationX")
	self.accelerationY = data.get("accelerationY")
	self.knockbackStrength = data.get("knockbackStrength")
	self.bulletsPerBurst = data.get("bulletsPerBurst")
	self.burstDelay = data.get("burstDelay")
	if (data.has("burstType")): self.burstType = data.get("burstType")
	if (data.has("perBurstDirection")): self.perBurstDirection = data.get("perBurstDirection")
	if (data.has("perBulletDirection")): self.perBulletDirection = data.get("perBulletDirection")
	self.spreadRandom = data.get("spreadRandom")
	self.spreadFixed = data.get("spreadFixed")
	self.waveAmplitude = data.get("waveAmplitude")
	self.phaseSpeed = data.get("phaseSpeed")
	self.isHoming = data.get("isHoming")
	self.isAutoaim = data.get("isAutoaim")
	self.isCenteraim = data.get("isCenteraim")
	self.isBeam = data.get("isBeam")
	if (data.has("beamWidth")): self.beamWidth = data.get("beamWidth")
	if (data.has("beamInterval")): self.beamInterval = data.get("beamInterval")
	self.autoaimSpeed = data.get("autoaimSpeed")
	self.homingTurnSpeed = data.get("homingTurnSpeed")
	self.duration = data.get("duration")
	self.numberPenetrate = data.get("numberPenetrate")
	self.areaOfEffect = data.get("areaOfEffect")
	if (data.has("aoeOnDeath")): self.aoeOnDeath = data.get("aoeOnDeath")
	if (data.has("spawnChildrenOnDeath")): self.spawnChildrenOnDeath = data.get("spawnChildrenOnDeath")
	if (data.has("prediction")): self.prediction = data.get("prediction")
	if (data.has("maxDistance")): self.maxDistance = data.get("maxDistance")
	if (data.has("startSize")): self.startSize = data.get("startSize")
	if (data.has("endSize")): self.endSize = data.get("endSize")
	if (data.has("radialRadius")): self.radialRadius = data.get("radialRadius")
	if (data.has("radialSpeed")): self.radialSpeed = data.get("radialSpeed")
	if (data.has("isShield")): self.isShield = data.get("isShield")
	if (data.has("children")):
		self.maxGenerations = (data.get("children") as Dictionary).get("maxGenerations")
		var tmpArray : Array = (data.get("children") as Dictionary).get("generationBullets") as Array
		for i in range(tmpArray.size()):
			self.generationBullets.push_back(tmpArray[i] as int)
		self.childrenSpreadFixed = (data.get("children") as Dictionary).get("childrenSpreadFixed")
		self.childrenSpreadRandom = (data.get("children") as Dictionary).get("childrenSpreadRandom")
		self.childrenDirection = (data.get("children") as Dictionary).get("childrenDirection")
		self.childrenAutoAim = (data.get("children") as Dictionary).get("childrenAutoAim")
		self.childrenInstant = (data.get("children") as Dictionary).get("childrenInstant")
		self.childrenAreaOfEffect = (data.get("children") as Dictionary).get("childrenAreaOfEffect")
		if ((data.get("children") as Dictionary).has("childrenAoeOnDeath")): self.childrenAoeOnDeath = (data.get("children") as Dictionary).get("childrenAoeOnDeath")
		self.childMinDamage = (data.get("children") as Dictionary).get("childMinDamage")
		self.childMaxDamage = (data.get("children") as Dictionary).get("childMaxDamage")
		self.childInitialSpeed = (data.get("children") as Dictionary).get("childInitialSpeed")
		self.childAccelerationX = (data.get("children") as Dictionary).get("childAccelerationX")
		self.childIsHoming = (data.get("children") as Dictionary).get("childIsHoming")
		self.childHomingSpeed = (data.get("children") as Dictionary).get("childHomingSpeed")
		self.childDuration = (data.get("children") as Dictionary).get("childDuration")
		self.childMaxDistance = (data.get("children") as Dictionary).get("childMaxDistance")
		
	if (self.isAutoaim):
		$AutoTarget.visible = true
		
func upgradesFromData(data: Array):
	for item : Dictionary in data:
		self.upgradeLevels[item.label] = item
		
func spawnBullet(index: int):
	var newBullet = bulletScene.instantiate()
	newBullet.position = self.global_position
	newBullet.speedX = self.initialSpeed + randi_range(-self.initialSpeedRandom,self.initialSpeedRandom)
	newBullet.accelerationX = self.accelerationX
	newBullet.accelerationY = self.accelerationY
	newBullet.knockbackStrength = self.knockbackStrength
	
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
		var localTarget : EnemyBase = self.getNearestEnemy(self.global_position, []);
		# initial rotation?
		if (localTarget):
			pass
			# newBullet.direction = calculate_angle_between_positions(self.global_position, localTarget.global_position)
	
	
	var newDirection = self.direction
	if (bulletsPerBurst > 1):
		# first fixed spread
		if (self.spreadFixed > 0):
			if (self.burstSide == 1):
				newDirection = self.direction - self.spreadFixed + ( (self.spreadFixed * 2) / (self.bulletsPerBurst-1)) * index
			if (self.burstSide == -1):
				newDirection = self.direction + self.spreadFixed - ( (self.spreadFixed * 2) / (self.bulletsPerBurst-1)) * index
	# then add random
	if (self.spreadRandom > 0):
		var random_angle = int(randf_range(-self.spreadRandom, self.spreadRandom))
		newDirection += random_angle
	newBullet.direction = newDirection
	
	if (self.perBulletDirection):
		self.direction = int(self.direction + self.perBulletDirection) % 360
	
	self.phaseDirection = -self.phaseDirection
	newBullet.waveAmplitude = self.waveAmplitude
	newBullet.phaseSpeed = self.phaseSpeed
	newBullet.setDirection(self.phaseDirection)
	newBullet.damage = self.getDamage()
	newBullet.duration = self.duration
	newBullet.maxDuration = self.duration
	newBullet.maxDistance = self.maxDistance
	newBullet.isBeam = self.isBeam
	newBullet.isShield = self.isShield
	newBullet.numberPenetrate = self.numberPenetrate
	newBullet.areaOfEffect = self.areaOfEffect
	newBullet.startSize = self.startSize
	newBullet.endSize = self.endSize
	newBullet.beamWidth = self.beamWidth
	newBullet.beamInterval = self.beamInterval
	newBullet.radialRadius = self.radialRadius
	newBullet.radialSpeed = self.radialSpeed
	newBullet.aoeOnDeath = self.aoeOnDeath
	
	self.find_parent("Space").add_child(newBullet)
	newBullet.connect("hit", Callable(self, "_on_bullet_hit"))
	newBullet.connect("die_signal", Callable(self, "_on_bullet_die"))
	
	playSound()

func spawnChildBullet(bullet:BulletBase, generation:int, index:int):
	var newBullet = bulletScene.instantiate()
	newBullet.position = bullet.global_position
	newBullet.speedX = self.childInitialSpeed
	newBullet.accelerationX = self.childAccelerationX
	newBullet.accelerationY = 0
	newBullet.knockbackStrength = self.knockbackStrength
	newBullet.childGeneration = generation + 1 
	
	var newDirection = bullet.direction
	# first fixed spread
	if (self.childrenSpreadFixed > 0):
		var step = (self.childrenSpreadFixed * 2) / (self.generationBullets[generation]-1)
		if (self.childrenSpreadFixed == 180): step = (self.childrenSpreadFixed * 2) / (self.generationBullets[generation])
		newDirection = bullet.direction - self.childrenSpreadFixed + step * index
	# then add random
	if (self.childrenSpreadRandom > 0):
		var random_angle = int(randf_range(-self.childrenSpreadRandom, self.childrenSpreadRandom))
		newDirection += random_angle
	newBullet.direction = newDirection
	
	# instant aim
	if (self.childrenInstant):
		for area in bullet.hitEnemies:
			newBullet.hitEnemies.push_back(area)
			
		var target = self.getNearestEnemy(bullet.global_position, newBullet.hitEnemies)
	
		var angle : float;
		if (target):
			var targetPoint = target.global_position;
			angle = self.calculate_angle_between_positions(bullet.global_position, targetPoint)
			newBullet.direction = angle
			bullet.hitEnemies.push_back(target.get_node("Area2D"))
		else:
			pass
	
	var angle_radians = deg_to_rad(newBullet.direction)
	var forward_velocity = Vector2(cos(angle_radians) * 10, sin(angle_radians) * 10)
	newBullet.position += forward_velocity
	newBullet.damage = self.getChildDamage()
	newBullet.duration = self.childDuration
	newBullet.maxDistance = self.childMaxDistance
	newBullet.aoeOnDeath = self.childrenAoeOnDeath
	newBullet.areaOfEffect = self.childrenAreaOfEffect
	
	if (bullet.hitEnemies.size()):
		newBullet.ignoreEnemies.push_back(bullet.hitEnemies[0])
	
	self.find_parent("Space").add_child(newBullet)
	newBullet.connect("hit", Callable(self, "_on_bullet_hit"))
	newBullet.connect("die_signal", Callable(self, "_on_bullet_die"))
	
	playSound()

func startBurst():
	if not self.firing_burst:
		self.firing_burst = true
		self.bullets_fired = 0
		timer.wait_time = self.burstDelay
		timer.start()
		self._on_timer_timeout() # fire first bullet directly
		
func _on_timer_timeout():
	if self.bullets_fired < bulletsPerBurst:
		# Spawn a bullet
		self.spawnBullet(self.bullets_fired)
		self.bullets_fired += 1
		timer.start()  # Restart the timer for the next bullet
	else:
		# End of the burst
		self._on_burst_end()
		self.firing_burst = false
		timer.wait_time = self.burstDelay
		timer.stop()
		print("end of burst")
		shotCooldown += shotDelay
		# timer.start()  # Start timer for the next burst

func _on_burst_end():
	if (self.burstType == 1): self.burstSide *= -1
	if (self.burstType == 2): self.direction = int(self.direction + 180) % 360
	if (self.perBurstDirection):
		self.direction = int(self.direction + self.perBurstDirection) % 360

func _on_bullet_hit(damage:float):
	dps_meter.add_damage(damage)
	self.playHit()		
	
func getNearestEnemy(position:Vector2, ignorelist:Array) -> EnemyBase:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var target:EnemyBase= null
	var targetdistance : float = 9999999
	for enemy:EnemyBase in enemies:
		if enemy.get_node("Area2D") in ignorelist: continue
		var distance = position.distance_squared_to(enemy.global_position)
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
	
	var target = self.getNearestEnemy( self.global_position, [])
	
	var angle : float;
	if (target):
		var targetPoint = target.global_position;
		# movement prediction
		var distance = self.global_position.distance_to(targetPoint)
		# how long to get there
		var duration = distance / self.initialSpeed; 
		targetPoint = targetPoint + (target.movement * duration * prediction);
		
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
		
func getChildDamage() -> int:
	return int(round(randi_range(self.childMinDamage * 10 - 5, self.childMaxDamage * 10 + 4) / 10.0))

		
func _on_bullet_die(bullet:BulletBase):
	
	if (self.areaOfEffect > 0 && self.deathScene):
		var death = self.deathScene.instantiate()
		death.global_position = bullet.global_position
		death.setSize(self.areaOfEffect)
		self.find_parent("Space").add_child(death)
		
	if (self.maxGenerations > 0):
		var generation = bullet.childGeneration
		if (generation >= self.maxGenerations): return
		print("generation: "+str(generation))
		for i in range(self.generationBullets[generation]):
			self.spawnChildBullet(bullet, generation, i)
	

func getDPSOutput() -> String:
	var text : String = self.name + " "+ str(dps_meter.calculate_dps()).pad_decimals(1)+" / "+str(dps_meter.total_damage).pad_decimals(0)
	text += " | CD: " + str(self.shotCooldown).pad_decimals(2)
	return text
	
func getCooldownPercentage() -> float:
	if (self.shotDelay > 0): return self.shotCooldown / self.shotDelay
	return 0
	
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
		

# close enough to normalized distribution
func getDamage() -> int:
	return int(round(randi_range(self.shotMinDamage * 10 - 5, self.shotMaxDamage * 10 + 4) / 10.0))

# should generally be overwritten
func getPossibleUpgrades() -> Array[Upgrade]:
	var upgrades : Array[Upgrade] = [];
	for key in self.upgradeLevels:
		var item : Dictionary = self.upgradeLevels[key]
		if (item.level < 9):
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
		if (prop['prop'] == "generationBullets"):
			var tmpArray : Array = prop['values'][item['level']] as Array
			for i in range(tmpArray.size()):
				if (self.generationBullets.size() < i+1): self.generationBullets.push_back(0)
				self.generationBullets[i] = tmpArray[i] as int
		else:
			self[prop['prop']] = prop['values'][item['level']]
	#if (upgrade.feature == "cooldown"):
	#	self.shotDelay *= 0.95
	#else:
#		push_warning("Unknown upgrade feature ", upgrade.feature)
