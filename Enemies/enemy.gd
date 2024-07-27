extends Node2D
class_name Enemy

var movement: Vector2

signal exited_screen(who: Enemy)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_movement(speed: float, spread: float):
	self.movement = Vector2( -speed, 0)
	var angle = randf_range(-spread, spread)
	self.movement = self.movement.rotated(deg_to_rad(angle))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position += self.movement * delta
	
	if (self.position.x < -100):
		# well off-screen
		self.exited_screen.emit(self)
