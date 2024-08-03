extends Node2D
class_name WeaponBase

var firing = false
@export var sound : AudioStreamMP3
var soundplayer : AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	soundplayer = AudioStreamPlayer.new()
	soundplayer.volume_db = -20
	add_child(soundplayer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func startFiring():
	firing = true
	
func stopFiring():
	firing = false

func playSound():
	# Check if the sound and soundplayer are set
	if sound and soundplayer:
		# Stop any currently playing sound
		soundplayer.stop()
		# Assign the sound to the player
		soundplayer.stream = sound
		# Play the sound from the beginning
		soundplayer.play()
	else:
		pass
		# print("Sound or SoundPlayer is not set.")
