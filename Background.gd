extends Sprite2D

# Speed of offset in pixels per second
var speed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Calculate the new offset
	offset.x -= speed * delta

	# Check if the offset is less than -1366
	if offset.x < -1366:
		offset.x += 1366

	# Apply the new offset to the sprite
	# position.x = offset.x
