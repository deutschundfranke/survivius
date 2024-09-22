extends "res://Weapons/bullet_base.gd"
class_name SparksBullet

var speed = 200
var maxDistance = 200
var distance = 0
var direction = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	self.damage = 0.5
	pass # Replace with function body.

func setDirection(_direction):
	self.direction = _direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var xmove = speed * delta * cos(self.direction)
	var ymove = speed * delta * sin(self.direction)
	self.position.x += xmove
	self.position.y += ymove
	self.distance += absf(xmove) + absf(ymove)
	if (self.distance > self.maxDistance):
		self.queue_free()
