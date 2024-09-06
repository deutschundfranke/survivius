extends AudioStreamPlayer

# Preload the audio files and store them in an array
var tracks = [
	preload("res://music/DnB - Rain Walker Loop.mp3"),
	preload("res://music/DnB - Flow Loop.mp3"),
	preload("res://music/DnB - Heart Strings Loop.mp3"),
	preload("res://music/DnB - Supersonic Loop.mp3")
]

var current_track = 0  # To track the current song index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		# Play the first track
	play_next_track()

	# Connect the 'finished' signal to call `play_next_track` when a song finishes
	connect("finished", Callable(self, "play_next_track"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# Function to play the next track
func play_next_track():
	# Set the audio stream to the current track
	stream = tracks[current_track]
	
	# Play the current track
	play()
	
	# Move to the next track in the list, loop if at the end
	current_track = (current_track + 1) % tracks.size()
