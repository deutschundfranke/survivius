extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_pressed("up")):
		self.move_local_y(-100 * delta)
		if (self.position.y < 0):
			self.position.y = 0
	if (Input.is_action_pressed("down")):
		self.move_local_y(100 * delta)
		if (self.position.y > 1000):
			self.position.y = 1000
