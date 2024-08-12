extends Area2D

@export var verticalOnly: bool
@export var maxSpeed = 100
@export var weapons: Array[WeaponBase] = []

var targetPos: Vector2
var velocity: Vector2 = Vector2()  # Initial velocity
@export var accelleration: float = 2000  # Acceleration rate in pixels per second squared
var moveMode = 'mouse'

# Called when the node enters the scene tree for the first time.
func _ready():
	self.targetPos = self.position
	for weapon in self.weapons:
		weapon.startFiring()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# apply a more accelleration based movement
	accellerate(delta)
	
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
	
	global_position += velocity * delta
	global_position = global_position.clamp(Vector2(0, 0), get_viewport_rect().size)
	
