extends Node

var time : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.time += delta
	$Label.text = format_time(self.time)
	# print(format_time(self.time))
	
# Function to convert seconds to HH:MM format
func format_time(time: float) -> String:
	var seconds = int(time) % 60  # Convert seconds to hours
	var minutes = (int(time) % 3600) / 60  # Convert remaining seconds to minutes

	# Return a formatted string in HH:MM, padded with zeros
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
