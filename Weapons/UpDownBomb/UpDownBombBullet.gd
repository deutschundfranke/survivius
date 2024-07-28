extends "res://Weapons/bullet_base.gd"
class_name UpDownBombBullet

@export var speed = 200
@export var yspeed = 0
@export var yaccel = 20
var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	self.damage = 3
	pass # Replace with function body.

func setDirection(_direction):
	self.direction = _direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.x += speed * delta
	if (self.position.x > 1000):
		self.queue_free()
	yspeed += yaccel * direction * delta
	self.position.y += yspeed
