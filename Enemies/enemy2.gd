extends EnemyBase
class_name Enemy2

# Called when the node enters the scene tree for the first time.
func _ready():
	self.sprite = $Sprite2D  # Adjust the path as needed
	self.shader_material = sprite.material as ShaderMaterial
	self.phase = 1
	self.movement = Vector2(-400,0)
	
func set_movement(speed: float, spread: float):
	self.movement = Vector2( -speed, 0)
	var angle = randf_range(-spread, spread)
	self.movement = self.movement.rotated(deg_to_rad(angle))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (self.phase == 1):
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			var playership : Node2D = players[0]
			var distanceX : float = self.global_position.x - playership.global_position.x
			var distanceY : float = self.global_position.y - playership.global_position.y
			
			if (distanceX <= 50):
				self.phase = 2
				var degrees : int = 90
				if (distanceY < 0):
					degrees = -90
				self.rotation_degrees = degrees
				self.movement = self.movement.rotated(deg_to_rad(degrees))
			
	self.position += self.movement * delta
	# Super is automatically called
	super(delta)
