extends EnemyBase
class_name EnemyUBER

var phases : Array = []
var currentPhase : int = 0
var wiggle : float = 0
var wiggleSpeed : float = 0
var wiggleStrength : float = 0
var rotatePhase : float = 0
var rotateSpeed : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	self.sprite = $Sprite2D  # Adjust the path as needed
	self.shader_material = sprite.material as ShaderMaterial
	
func set_movement(speed: float, spread: float):
	self.movement = Vector2( -speed, 0)
	var angle = randf_range(-spread, spread)
	self.movement = self.movement.rotated(deg_to_rad(angle))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if (self.acceleration.x > 0):
		self.movement.x += self.acceleration.x * delta
	
	self.position += self.movement * delta
	
	# get player
	var playership : Node2D
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		playership = players[0]
	
	# wiggle
	if (self.wiggleStrength > 0):
		self.wiggle += delta * self.wiggleSpeed
		self.rotation_degrees = cos(self.wiggle) * self.wiggleStrength
	
	# rotate
	if (self.rotateSpeed > 0):
		self.rotatePhase += delta;
		self.rotation_degrees = self.rotatePhase * 500;
	
	# check phase triggers
	var phase : Dictionary = self.phases[currentPhase]
	if (phase.has("triggers") ):
		for trigger : Dictionary in phase.get("triggers") as Array:
			match trigger.get("type"):
				"distanceX":
					var value = float(trigger.get("value"))
					var distanceX = absf(playership.global_position.x - self.global_position.x)
					if (distanceX <= value):
						self.initPhase(int(trigger.targetPhase))
				"speedXMin":
					var value = float(trigger.get("value"))
					if (self.movement.x <= value):
						self.initPhase(int(trigger.targetPhase))
				"speedXMax":
					var value = float(trigger.get("value"))
					if (self.movement.x >= value):
						self.initPhase(int(trigger.targetPhase))
	
	# Super is automatically called
	super(delta)
	
func setPhases(phases:Array):
	self.phases = phases
	self.initPhase(1)
	
func initPhase(index:int):
	var phase = self.phases[index-1]
	var viewport = get_viewport_rect().size
	
	# new rotation
	if phase.has("rotation"):
		var rotation : float = float(phase.rotation)
		if phase.has("rotationTarget"):
			if phase.get("rotationTarget") == "centerY":
				if (self.global_position.y < viewport.y / 2):
					rotation = -rotation
		self.rotation_degrees = rotation
		self.movement = self.movement.rotated(deg_to_rad(rotation))
	
	# acceleration
	if (phase.has("accelerationX")):
		self.acceleration.x = float(phase.get("accelerationX"))
	
	# wiggle
	if (phase.has("wiggleSpeed")): self.wiggleSpeed = phase.get("wiggleSpeed")
	if (phase.has("wiggleStrength")): self.wiggleStrength = phase.get("wiggleStrength")
	# rotate
	if (phase.has("rotateSpeed")): self.rotateSpeed = phase.get("rotateSpeed")
	
	currentPhase = index-1
