extends Node2D
class_name BulletBase

signal hit_enemy(enemy)
signal hit()
signal die_signal()

var damage : float = 1
var velocity : Vector2 = Vector2(1,0)
var hitEnemies : Array = []
var ignoreEnemies : Array = []

var speedX = 200
var speedY = 0
# var velocity = Vector2()
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
var homingTurnSpeed : float = 0
var homingTarget : EnemyBase
var numberPenetrate : int = 0
var areaOfEffect : float = 0
var areaOfEffectTriggered : bool = false
var duration : float = 15
var maxDuration : float = 15
var distance : float = 0
var maxDistance : float = 0
var isBeam : bool = false
var childGeneration : int = 0
var startSize : float = 0
var endSize : float = 0

var basePosition : Vector2;
var deltaPosition : Vector2;

@onready var sprite = $Sprite2D
@onready var collision_shape = $Area2D/AreaOfEffect

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D.connect("area_entered", Callable(self, "_on_CollisionArea_area_entered"))
	self.basePosition = self.position
	self._process(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if (self.isBeam):
		# Placeholder
		#$Sprite2D.position.x = 12
		#$Area2D.position.x = 12
		
		#self.scale = Vector2(50,1)
		self.duration -= delta
		if (self.duration <= 0):
			self.queue_free()
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			var playership : Node2D = players[0]
			self.global_position = playership.global_position
		
	
	# if bullet is slowing down, make it stop
	if (self.speedX < 0 && accelerationX > 0 && self.speedX + accelerationX * delta > 0):
		accelerationX = 0
		speedX = 0
	self.speedX += accelerationX * delta
	self.speedY += accelerationY * delta
	
	# homing, get new target
	if (self.isHoming):
		if (self.homingTarget == null):
			self.homingTarget = self.getNearestEnemy()
		if (self.homingTarget):
			rotate_bullet_towards_target(delta)
	
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
	
	self.rotation = angle_radians
	
	# wave movement
	# Calculate sine wave displacement perpendicular to the velocity direction
	var perpendicular_displacement = self.waveAmplitude * sin(phase)
	
	# Determine the perpendicular direction vector
	var perpendicular_direction = Vector2(-velocity.y, velocity.x).normalized()

	# Apply the perpendicular sine displacement to the bullet's position
	self.deltaPosition = perpendicular_direction * perpendicular_displacement
	# self.deltaPosition = Vector2(0, perpendicular_displacement)
	
	if (!self.isBeam):
		self.position = self.basePosition + self.deltaPosition
	
	# var viewport_size = get_viewport().
	
	# size
	if (self.startSize != 0 && self.endSize != 0):
		var percent = 1 - (self.duration / self.maxDuration)
		percent = 1 - (1 - percent) * (1 - percent)
		var targetSize = self.startSize + (self.endSize - self.startSize) * percent
		var texture_size = $Sprite2D.texture.get_size()
		# Calculate scale factors for width and height
		var scale_x = targetSize / texture_size.x
		var scale_y = targetSize / texture_size.y
		# Apply the scale
		$Sprite2D.scale = Vector2(scale_x, scale_y)
		$Area2D/CollisionShape2D.shape.radius = targetSize / 2
	
	var viewport_size = get_viewport().get_visible_rect().size
	if (self.position.x > viewport_size.x + 100):
		self.queue_free()
	if (self.position.x < -100):
		self.queue_free()
	if (self.position.y < -100):
		self.queue_free()
	if (self.position.y > viewport_size.y + 100):
		self.queue_free()
		
	# duration show down
	self.duration -= delta
	if (self.duration <= 0):
		self.queue_free()
		
	if (self.maxDistance > 0):
		self.distance += (velocity * delta).length()
		if (self.distance > self.maxDistance):
			self.queue_free()
	
func _on_CollisionArea_area_entered(area):
	if area.get_parent().is_in_group("enemies"):
		if (ignoreEnemies.has(area)): return
		hitEnemies.push_back(area)
		area.get_parent().take_damage(self.damage, self.velocity)
		emit_signal("hit",self.damage) # signal approach
		# emit_signal("hit_enemy", area) # signal approach
		var will_die : bool = true
		if ("isBeam" in self && self.isBeam):
			will_die = false
		if ("numberPenetrate" in self && self.numberPenetrate > 0):
			self.numberPenetrate -= 1
			will_die = false
		if ("areaOfEffect" in self && self.areaOfEffect > 0):
			self.onAreaOfEffect()
			will_die = false
		if (will_die):
			self.die()  # Optionally, you can free the bullet after hitting the enemy
		
func die():
	emit_signal("die_signal", self)
	queue_free()
	
func setDirection(_direction):
	self.phaseDirection = _direction
	if (self.phaseDirection == -1): phase = PI

func calculate_angle_between_positions(A: Vector2, B: Vector2) -> float:
	# Calculate the direction vector from A to B
	var direction = B - A

	# Calculate the angle in radians using atan2
	var angle_radians = atan2(direction.y, direction.x)

	# Convert the angle from radians to degrees
	var angle_degrees = rad_to_deg(angle_radians)

	return angle_degrees

func rotate_bullet_towards_target(delta: float) -> void:
	
	var angle : float = self.rotation_degrees;
	if (self.homingTarget):
		angle = self.calculate_angle_between_positions(self.global_position, self.homingTarget.global_position)
	#else:
		#self.autoaimTarget = 0
	
	# Calculate the difference between the target angle and the current angle
	var angle_difference: float = angle - self.direction
	
	# Normalize the angle to be within the range of -180 to 180 degrees
	angle_difference = fmod(angle_difference + 180, 360) - 180

	# Calculate the maximum rotation step we can take this frame
	var rotation_step: float = homingTurnSpeed * delta

	# Determine the direction and rotate towards the target angle
	if abs(angle_difference) <= rotation_step:
		# If the difference is small enough, snap to the target angle
		self.direction = angle
	else:
		# Rotate in the shortest direction towards the target
		self.direction += sign(angle_difference) * rotation_step

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
	
func onAreaOfEffect():
	if areaOfEffectTriggered:
		return
	
	areaOfEffectTriggered = true
	
	collision_shape = CollisionShape2D.new()
	collision_shape.visible = true
	$Area2D.add_child(collision_shape)
	
	var new_circle_shape = CircleShape2D.new()
	new_circle_shape.radius = self.areaOfEffect

	collision_shape.shape = new_circle_shape
	
	# Queue the bullet for deletion in the overnext frame
	await get_tree().process_frame # Wait for the next frame
	await get_tree().process_frame # Wait for the overnext frame
	self.die()  # Queue the bullet for deletion
