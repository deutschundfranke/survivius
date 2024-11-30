extends Node

var duration : float = 0.15;
var sprite : AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Duplicate the SpriteFrames resource to make it local
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.duration = self.duration - delta
	if (self.duration < 0): self.queue_free()
	pass
	
func setSize(size:float):
	print("set Size outside")
	self.sprite = $Sprite2D
	$Sprite2D.visible = false
	self.sprite.visible = true
	# add_child(self.sprite)
	self.sprite.play("default")
	
	size = size * 2
	print(size)
	if self.sprite.sprite_frames:  # Ensure the AnimatedSprite2D has frames
		print("set Size inside")
		var sprite_frames = self.sprite.sprite_frames
		var animation_name = self.sprite.animation  # Current animation name

		if sprite_frames.get_frame_count(animation_name) > 0:  # Ensure the animation has frames
			# Get the texture of the first frame
			var texture = sprite_frames.get_frame_texture(animation_name, 0)
			if texture:  # Ensure the frame has a texture
				var texture_size = texture.get_size()

				# Calculate scale factors for width and height
				var scale_x = size / texture_size.x
				var scale_y = size / texture_size.y

				# Apply the scale to the node
				self.sprite.scale = Vector2(scale_x, scale_y)
				print(scale_x)
