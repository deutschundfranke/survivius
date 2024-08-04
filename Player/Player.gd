extends Area2D

@export var verticalOnly: bool
@export var maxSpeed = 100
@export var weapons: Array[WeaponBase] = []

var targetPos: Vector2
var velocity: Vector2 = Vector2()  # Initial velocity
@export var acceleration: float = 2000  # Acceleration rate in pixels per second squared

# Called when the node enters the scene tree for the first time.
func _ready():
	self.targetPos = self.position
	for weapon in self.weapons:
		weapon.startFiring()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if (Input.is_action_pressed("up")):
		#self.move_local_y(-100 * delta)
		#if (self.position.y < 0):
			#self.position.y = 0
	#if (Input.is_action_pressed("down")):
		#self.move_local_y(100 * delta)
		#if (self.position.y > 1000):
			#self.position.y = 1000
			
	# apply a more acceleration based movement
	accelerate_towards_target(delta)
	# self.moveToTarget(delta)
	
func setTargetPos(newTarget: Vector2):
	self.targetPos = newTarget

func moveToTarget(delta):
	var distance: Vector2 = (self.targetPos - self.position)
	if (distance.length() < 1.0):
		self.position = self.targetPos
		return
	
	if (self.verticalOnly):
		distance.x = 0.0
	
	var maxSpeedNow = self.maxSpeed * delta
	if (distance.length() > maxSpeedNow):
		# distance = distance.normalized() * maxSpeedNow
		distance = self.direction * maxSpeedNow
	self.position = self.position + distance
	
	# clamp position

func accelerate_towards_target(delta):
	
	# if target is reached, slow down
	if (self.targetPos == Vector2(-1,-1)):
		velocity -= velocity * 0.10
		global_position += velocity * delta
		return
	
	# Calculate the direction to the target
	var direction_to_target = (self.targetPos - global_position).normalized()
	
	# Calculate the acceleration vector
	var acceleration_vector = direction_to_target * acceleration * delta
	
	# Update the velocity
	velocity += acceleration_vector
	
	# if target reached, set targetPos to "off"
	var distance: Vector2 = (self.targetPos - self.position)
	if (distance.length() < 60):
		self.targetPos = Vector2(-1,-1)
		
	# Clamp the speed to the maximum value
	if velocity.length() > maxSpeed:
		velocity = velocity.normalized() * maxSpeed
	
	# Print the current velocity for debugging purposes
	# print("Current Velocity: ", velocity)
	
	# move as Node2D
	global_position += velocity * delta
