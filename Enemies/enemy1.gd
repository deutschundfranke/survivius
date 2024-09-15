extends EnemyBase
class_name Enemy1

var wiggle : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.sprite = $Sprite2D  # Adjust the path as needed
	self.shader_material = sprite.material as ShaderMaterial
	
func set_movement(speed: float, spread: float):
	self.movement = Vector2( -speed, 0)
	var angle = randf_range(-spread, spread)
	self.movement = self.movement.rotated(deg_to_rad(angle))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position += self.movement * delta
	
	self.wiggle += delta * 15
	self.rotation_degrees = cos(self.wiggle) * 12
	# Super is automatically called
	super(delta)
