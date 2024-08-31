extends "res://Weapons/bullet_base.gd"
class_name UBERBullet

var speedX = 200
var speedY = 0
var velocity = Vector2()
var accelerationX : float = 0.0
var accelerationY : float = 0.0
var direction : float = 0.0
var waveAmplitude : float = 0
var waveType : int = 0
var waveStartPosition = 0
var phaseSpeed = 6
var phaseDirection = 1
var phase = 0
var isHoming : bool = false
var numberPenetrate : int = 0

var basePosition : Vector2;
var deltaPosition : Vector2;

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	self.basePosition = self.position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	self.speedX += accelerationX * delta
	self.speedY += accelerationY * delta
	
	# Wave ## work with direction
	#self.speedY += cos(phase) * self.waveAmplitude
	self.phase += self.phaseSpeed * delta
	
	var angle_radians = deg_to_rad(direction)
	# Calculate forward velocity components along the angle direction
	var forward_velocity = Vector2(cos(angle_radians), sin(angle_radians)) * speedX
	# Calculate sideways velocity vector perpendicular to the forward direction
	var sideways_velocity = Vector2(-sin(angle_radians), cos(angle_radians)) * speedY
	# Combine both velocities
	velocity = forward_velocity + sideways_velocity
	
	self.basePosition += velocity * delta;
	# position += velocity * delta
	
	# wave movement
	# Calculate sine wave displacement perpendicular to the velocity direction
	var perpendicular_displacement = self.waveAmplitude * sin(phase)
	
	# Determine the perpendicular direction vector
	var perpendicular_direction = Vector2(-velocity.y, velocity.x).normalized()

	# Apply the perpendicular sine displacement to the bullet's position
	self.deltaPosition = perpendicular_direction * perpendicular_displacement
	# self.deltaPosition = Vector2(0, perpendicular_displacement)
	
	self.position = self.basePosition + self.deltaPosition
	
	if (self.position.x > 1200):
		self.queue_free()
		
func setDirection(_direction):
	self.phaseDirection = _direction
	if (self.phaseDirection == -1): phase = PI
