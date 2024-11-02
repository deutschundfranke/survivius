extends Control

# Cooldown percentage (1.0 = 100%, 0.0 = 0%)
var cooldown_percentage: float = 1.0

# Radius and thickness of the arc
@export var radius: float = 50.0
@export var thickness: float = 10.0

# Color of the cooldown overlay (50% black)
@export var cooldown_color: Color = Color(0, 0, 0, 0.5)

# Number of segments to approximate the arc (higher value = smoother arc)
@export var arc_segments: int = 30

func _ready():
	self.queue_redraw()  # Initial draw

# Call this method to update the cooldown percentage
func set_cooldown_percentage(percentage: float) -> void:
	cooldown_percentage = clamp(percentage, 0.0, 1.0)
	self.queue_redraw()  # Redraw on percentage change

func _draw():
	# Calculate the angle for the arc based on the cooldown percentage
	var start_angle = -PI / 2  # Starting at the top of the circle
	var end_angle = start_angle + cooldown_percentage * TAU  # TAU = 2 * PI
	
	# Center of the circle
	var center = Vector2(size.x / 2, size.y / 2)
	var angle_step = (end_angle - start_angle) / arc_segments

	for i in range(arc_segments):
		var angle_a = start_angle + i * angle_step
		var angle_b = angle_a + angle_step

		# Calculate the points for each segment triangle
		var point_a = center + Vector2(cos(angle_a), sin(angle_a)) * radius
		var point_b = center + Vector2(cos(angle_b), sin(angle_b)) * radius

		# Draw each triangle as a polygon with three points (center, point_a, point_b)
		draw_polygon([center, point_a, point_b], [cooldown_color])
