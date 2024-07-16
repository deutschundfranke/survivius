extends Sprite2D

@export var verticalOnly: bool
@export var maxSpeed = 100
var targetPos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	self.targetPos = self.position

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
			
	self.moveToTarget(delta)
	
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
		distance = distance.normalized() * maxSpeedNow
	self.position = self.position + distance
	
	# clamp position
