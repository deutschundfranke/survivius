extends Node2D

var dragging = false
signal clicked(position: Vector2)

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			self.dragging = event.pressed
			if (self.dragging):
				self.clicked.emit(event.position)
	if event is InputEventMouseMotion and self.dragging:
		self.clicked.emit(event.position)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
