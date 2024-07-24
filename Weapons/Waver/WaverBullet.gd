extends Node2D
class_name WaverBullet

@export var speed = 200
@export var maxAmplitude = 100
@export var phasespeed = 6
var direction = 1
var phase = 0
var yStartPosition = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.yStartPosition = self.position.y
	pass # Replace with function body.

func setDirection(_direction):
	self.direction = _direction
	if (self.direction == -1): phase = PI

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.x += speed * delta
	if (self.position.x > 1000):
		self.queue_free()
	self.position.y = self.yStartPosition + sin(phase) * self.maxAmplitude
		
	self.phase += self.phasespeed * delta
