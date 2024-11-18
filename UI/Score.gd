extends Node
class_name Score

var score : int = 0
var label : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label = $Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func onGainScore(gain: int, _curr, _max) -> void:
	score += gain
	label.text = "%d" % score
