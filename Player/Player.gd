extends CharacterBody2D
class_name Player

signal expGained(added: int, currentTotal: int, maxTotal: int)
signal levelIncreased(newLevel: int)

@export var verticalOnly: bool
@export var maxSpeed = 100
@export var weapons: Array[WeaponBase] = []
@export var armory: Armory = null
@export var level:int = 1;
@export var exp_current : int = 0;
@export var exp_needed : int = 0;
@export var exp_factor : float = 30.0
@export var modifier_maxspeed : float = 1.10;
@export var modifier_cooldown : float = 0.95;
@export var collectPlayer : AudioStreamPlayer;
@export var levelupPlayer : AudioStreamPlayer;
@export var hitPlayer : AudioStreamPlayer;
@export var tint_duration: float = 0.5
@export var collection_radius : float = 120
@export var collection_speed : float = 250
@export var collection_global_speed : float = 0
var health : int = 3;
@export var health_max : int = 3;

# Timer to manage the tint duration
var tint_timer: float = 0.0
# Reference to the player's sprite and its shader material
@onready var sprite: Sprite2D = $Sprite2D  # Adjust the path as needed
@onready var shader_material: ShaderMaterial = sprite.material as ShaderMaterial

var targetPos: Vector2
@export var accelleration: float = 2000  # Acceleration rate in pixels per second squared
var moveMode = 'mouse'

# Called when the node enters the scene tree for the first time.
func _ready():
	self.targetPos = self.position
	self.exp_needed = self.level * 10;
	#weapons[1].firing = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# apply a more accelleration based movement
	accellerate(delta)
	
	# If the tint timer is active, decrease it
	if tint_timer > 0:
		tint_timer -= delta
		
		# Update the shader tint strength
		shader_material.set_shader_parameter("tint_strength", 1.0)
		
		# When the timer runs out, revert to the original color
		if tint_timer <= 0:
			shader_material.set_shader_parameter("tint_strength", 0.0)
	
func setTargetPos(newTarget: Vector2):
	self.targetPos = newTarget
	self.moveMode = "mouse"

func getTargetVelocity():
	# see https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html#which-input-singleton-method-should-i-use
	var inputDir = Input.get_vector("left", "right", "up", "down")
	
	if (inputDir.length_squared() > 0.0):
		self.moveMode = 'keyboard'
	
	if (self.moveMode == 'keyboard'):
		return inputDir * maxSpeed
	else:
		var deltaPos = self.targetPos - self.position
		if (deltaPos.length_squared() < 20 * 20):
			return Vector2(0, 0)
		return deltaPos.normalized() * maxSpeed

func accellerate(delta):
	var targetVelocity: Vector2 = self.getTargetVelocity()
	
	var deltaVelocity: Vector2 = targetVelocity - velocity
	# need a formula here
	if (deltaVelocity.length_squared() < 4.0):
		velocity = targetVelocity
	else:
		var accellVec = deltaVelocity.normalized() * accelleration
		velocity += accellVec * delta
		
	if (velocity.length_squared() > maxSpeed * maxSpeed):
		velocity = velocity.normalized() * maxSpeed
	
	#global_position += velocity * delta
	self.move_and_slide()
	global_position = global_position.clamp(Vector2(0, 0), get_viewport_rect().size)
	
func gainEXP(value:int):
	self.exp_current += value;
	collectPlayer.play()
	if (self.exp_current >= self.exp_needed):
		self.levelUp();
		self.exp_current -= self.exp_needed
		self.exp_needed = self.level * self.exp_factor;
	var size : float = (self.exp_current / float(self.exp_needed)) * 40;
	self.expGained.emit(value, self.exp_current, self.exp_needed)
		
func levelUp():
	levelupPlayer.play()
	self.level += 1
	self.levelIncreased.emit(self.level)

func getPossibleUpgrades() -> Array[Upgrade]:
	var list: Array[Upgrade] = []
	# if we have *no weapons*, that's what we need
	if (self.enabledWeapons().size() == 0):
		var choices = self.availableWeapons()
		choices.shuffle()
		choices = choices.slice(0, 4) # 2
		list.append_array(choices.map(func (choice: WeaponBase) -> Upgrade:
			return Upgrade.new(
				"ship", "new_weapon", "New " + choice.name, Color.RED, "W+\n" + choice.label, choice.label
			)
		))
		# return directly; no other upgrade choices make sense
		return list
		
	# if there are still weapons unclaimed, offer one of them:
	var availableWeapon = self.pickRandomAvailableWeapon()
	if availableWeapon && self.weapons.size() < 6:
		list.append(Upgrade.new(
			"ship", "new_weapon", "New " + availableWeapon.name, Color.RED, "W+\n" + availableWeapon.label, availableWeapon.label
		))
		
	# only ask for health if we could use some healing
	if (self.health < self.health_max):
		list.append(Upgrade.new(
			"ship", "health", "À la vôtre!", Color.DARK_GREEN, "+"
		))
	# we can always go faster :-D
	list.append(Upgrade.new(
		"ship", "speed", "Speed up!", Color.YELLOW, '>>'
	))
	# collection radius 
	list.append(Upgrade.new(
		"ship", "collection", "Collect up!", Color.GRAY, '++'
	))
	
	for weapon in self.enabledWeapons():
		list.append_array(weapon.getPossibleUpgrades())
	
	return list

func applyUpgrade(upgrade: Upgrade):
	match [upgrade.target, upgrade.feature]:
		["ship", "new_weapon"]:
			self.addNewWeapon(upgrade.subtarget)
		["ship", "speed"]:
			self.maxSpeed *= self.modifier_maxspeed
		["ship", "collection"]:
			self.collection_radius += 80
			self.collection_speed += 20
			self.collection_global_speed += 5
		["ship", "health"]:
			self.heal(1)
		["all_weapons", "cooldown"]:
			for weapon in self.weapons:
				weapon.shotDelay *= self.modifier_cooldown
		["weapon", _]:
			var weapon = self.findWeaponByLabel(upgrade.subtarget)
			if (weapon):
				weapon.applyUpgrade(upgrade)

func enabledWeapons() -> Array[WeaponBase]:
	return self.weapons.filter(func (weapon):
		return weapon.firing
	)

func availableWeapons() -> Array:
	if self.armory:
		var x = armory.weapons.duplicate()
		return x
	return []

func pickRandomAvailableWeapon() -> WeaponBase:
	if not self.armory:
		return null
	return self.armory.weapons.pick_random()

func findWeaponByLabel(label: String) -> WeaponBase:
	var foundWeapon : WeaponBase = null;
	if self.armory:
		foundWeapon = self.armory.findWeaponByLabel(label)
	# if not found in armory, find in self
	if (foundWeapon == null):
		for weapon : WeaponBase in self.weapons:
			if (weapon.label == label):
				foundWeapon = weapon
	return foundWeapon

func addNewWeapon(label: String):
	var weapon = null
	if self.armory:
		weapon = self.armory.findWeaponByLabel(label) 
	if weapon:
		if self.armory:
			self.armory.removeWeapon(weapon)
		self.weapons.push_back(weapon)
		self.add_child(weapon)
		weapon.startFiring()

func getHit(damage : int):
	self.find_parent("Space").find_child("Camera2D").start_shake()
	self.tint_white()
	self.health -= damage
	self.hitPlayer.play()

	self.updateLifebar()
	
	if (self.health <= 0):
		self.die()

func heal(damage: int):
	self.health = min(self.health + damage, self.health_max)
	self.updateLifebar()

func updateLifebar():
	const colorOn = Color(0.0, 174.0 / 255.0, 0.0, 1.0)
	const colorOff = Color(0.5, 0.5, 0.5, 0.3)
	$Lifebar/Life1.color = colorOn if (self.health >= 1) else colorOff
	$Lifebar/Life2.color = colorOn if (self.health >= 2) else colorOff
	$Lifebar/Life3.color = colorOn if (self.health >= 3) else colorOff

	# Call this function to tint the player white
func tint_white():
	# Start the tint timer
	tint_timer = tint_duration

func die():
	get_tree().reload_current_scene()
