extends "res://Weapons/bullet_base.gd"
class_name WaverBullet

var speed = 200
var maxAmplitude = 100
var phasespeed = 6
var direction = 1
var phase = 0
var yStartPosition = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	self.yStartPosition = self.position.y
	self.damage = 1
	pass # Replace with function body.

func setDirection(_direction):
	self.direction = _direction
	if (self.direction == -1): phase = PI

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.x += speed * delta
	self.position.y = self.yStartPosition + sin(phase) * self.maxAmplitude
		
	self.phase += self.phasespeed * delta
	
	var viewport_size = get_viewport().get_visible_rect().size
	if (self.position.x > viewport_size.x + 100):
		self.queue_free()
	if (self.position.x < -100):
		self.queue_free()
	if (self.position.y < -100):
		self.queue_free()
	if (self.position.y > viewport_size.y + 100):
		self.queue_free()
