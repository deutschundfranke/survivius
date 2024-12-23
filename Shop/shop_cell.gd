extends Node2D
class_name ShopCell

signal collected(cell: ShopCell)

var height = 20
var upgrade: Upgrade

# Called when the node enters the scene tree for the first time.
func _ready():
	var area: Area2D = self.find_child("Area2D")
	area.body_entered.connect(onBodyEntered)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# movement is in the "bar" container
	pass

func setUpgrade(upgrade: Upgrade):
	self.upgrade = upgrade
	#self.setColor(upgrade.color)
	$Label.text = upgrade.name

func setHeight(newHeight: float):
	self.height = newHeight
	$Area2D.scale = Vector2(1, self.height/20)
	$BottomSeparator.position.y = self.height / 2

#func setColor(color: Color):
#	var polygon: Polygon2D = get_node("Area2D/Polygon2D")
#	polygon.color = color

func onBodyEntered(body: PhysicsBody2D):
	if body.is_in_group("Player"):
		self.collected.emit(self)
