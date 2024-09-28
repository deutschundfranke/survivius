extends Node2D
class_name Explosion


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CPUParticles2D.emitting = true
	# Wait for 0.1 seconds
	await get_tree().create_timer(0.3).timeout
	
	# Remove the node from the scene
	queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
