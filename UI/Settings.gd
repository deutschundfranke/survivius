extends CanvasLayer
class_name Settings

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed && !event.echo && event.physical_keycode == KEY_ESCAPE:
			self.togglePaused()

func togglePaused() -> void:
	var sceneTree = get_tree()
	if sceneTree.paused:
		sceneTree.paused = false
		self.hide()
	else:
		sceneTree.paused = true
		self.show()
