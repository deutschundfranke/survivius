extends Node
class_name ShopBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.x = self.position.x -60 * delta
	if self.global_position.x < -200:
		# this should never happen once collection is mandatory, but we should be prepared
		self.queue_free()
