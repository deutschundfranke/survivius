extends EnemyBase
class_name Enemy3

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	self.sprite = $Sprite2D  # Adjust the path as needed
	self.shader_material = sprite.material as ShaderMaterial
	self.phase = 1
	self.movement = Vector2(400,0)
	self.acceleration = Vector2(-600,0)
	
"""func set_movement(speed: float, spread: float):
	self.movement = Vector2( -speed, 0)
	var angle = randf_range(-spread, spread)
	self.movement = self.movement.rotated(deg_to_rad(angle))"""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (self.phase == 1):
		self.movement.x += self.acceleration.x * delta
		if (self.movement.x <= 80):
			self.phase = 2
			self.acceleration = Vector2(400,0)
	if (self.phase == 2):
		self.movement.x += self.acceleration.x * delta
				
	self.position += self.movement * delta
	
	var viewport = get_viewport_rect().size
	if (self.position.x > viewport.x + 100):
		# well off-screen
		self.exited_screen.emit(self)
	
	# Super is automatically called
	super(delta)
