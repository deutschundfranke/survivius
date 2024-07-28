extends "res://Weapons/bullet_base.gd"
class_name BlasterBullet

@export var speed = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	self.damage = 2
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.x += speed * delta
	if (self.position.x > 1000):
		self.queue_free()
