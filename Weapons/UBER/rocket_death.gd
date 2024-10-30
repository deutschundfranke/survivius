extends Node

var duration : float = 0.1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.duration = self.duration - delta
	if (self.duration < 0): self.queue_free()
	pass
	
func setSize(size:float):
	size = size * 2
	if $Sprite2D.texture:  # Ensure the sprite has a texture
		var texture_size = $Sprite2D.texture.get_size()

		# Calculate scale factors for width and height
		var scale_x = size / texture_size.x
		var scale_y = size / texture_size.y

		# Apply the scale
		$Sprite2D.scale = Vector2(scale_x, scale_y)
