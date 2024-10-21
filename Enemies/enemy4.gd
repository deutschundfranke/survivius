extends EnemyBase
class_name Enemy4

var rotatephase = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	self.sprite = $Sprite2D  # Adjust the path as needed
	self.shader_material = sprite.material as ShaderMaterial
	self.rotatephase = 0
	self.phase = 1
	self.health = 25
	self.movement = Vector2(-1200,150)
	self.acceleration = Vector2(300,0)
	var viewport = get_viewport_rect().size
	if (self.global_position.y > viewport.y / 2):
		self.movement.y = -150
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotatephase += delta;
	self.rotation_degrees = self.rotatephase * 500;
	
	self.movement.x += self.acceleration.x * delta
	self.position += self.movement * delta
	
	var viewport = get_viewport_rect().size
	if (self.position.x > viewport.x + 100):
		# well off-screen
		self.exited_screen.emit(self)
	
	# Super is automatically called
	super(delta)
