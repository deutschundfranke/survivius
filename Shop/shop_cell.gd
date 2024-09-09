extends Node2D
class_name ShopCell

signal collected(cell: ShopCell)

var height = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	self.randomizeColor()
	var area: Area2D = self.find_child("Area2D")
	area.area_entered.connect(onAreaEntered)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# movement is in the "bar" container
	pass

func setHeight(newHeight: float):
	self.height = newHeight
	$Area2D.scale = Vector2(1, self.height/20)

func setColor(color: Color):
	var polygon: Polygon2D = get_node("Area2D/Polygon2D")
	polygon.color = color

func randomizeColor():
	var color = Color(randf_range(0, 1.0), randf_range(0, 1.0), randf_range(0, 1.0))
	self.setColor(color)

func onAreaEntered(area: Area2D):
	if area.is_in_group("Player"):
		self.collected.emit(self)
