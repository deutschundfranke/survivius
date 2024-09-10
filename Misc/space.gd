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
	get_tree().root.connect("size_changed", Callable(self, "_on_viewport_size_changed"))
	self._on_viewport_size_changed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
# Capture window resize event using _notification
func _on_viewport_size_changed():
	print("resize 2")
	# Handle window resize event
	var viewport_rect = get_viewport().get_visible_rect()
	var scaled_viewport_size = viewport_rect.size
	$Expbar.position = Vector2(scaled_viewport_size.x - 50, scaled_viewport_size.y - 50)
	# Do something with the new window size
