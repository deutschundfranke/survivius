extends Node2D

# Shake intensity
@export var shake_intensity: float = 10.0
# Duration of the shake
@export var shake_duration: float = 0.2

# Internal state
var shake_timer: float = 0.0
var original_position: Vector2 = Vector2()

func _ready():
	# Store the original position of the camera
	original_position = position

func _process(delta):
	# If the shake timer is active, shake the camera
	if shake_timer > 0:
		shake_timer -= delta

		# Generate random offset
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		
		# Apply the offset to the camera's position
		position = original_position + shake_offset
		
		# If shake timer is over, reset the position
		if shake_timer <= 0:
			position = original_position

# Call this function to start the shake
func start_shake(intensity: float = 10.0, duration: float = 0.2):
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
