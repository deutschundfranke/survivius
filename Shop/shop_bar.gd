extends Node2D
class_name ShopBar

var cellScene: PackedScene
var collected: bool = false
var hasOffers: bool = false
var launched: bool = false
var fillAmount: float = 0.0 # 1.0 is filled

# TODO: besser auslesen.
var beamSize = Vector2(44, 1440)

signal upgradeSelected(upgrade: Upgrade)

# Called when the node enters the scene tree for the first time.
func _ready():
	var viewport = get_viewport_rect().size
	$BottomSeparator.position.y = viewport.y
	self.setFillAmount(0.0)

func createOffers(upgrades):
	var viewport = get_viewport_rect().size
	var cellNumber = upgrades.size()
	var cellHeight = viewport.y / float(cellNumber)
	for n in cellNumber:
		var cell: ShopCell = cellScene.instantiate()
		$Cells.add_child(cell)
		cell.setHeight(cellHeight)
		cell.position = Vector2(0, (n + 0.5) * cellHeight)
		cell.collected.connect(onCellCollected)
		cell.setUpgrade(upgrades[n])
	# Jede Zelle bringt ihren eigenen unteren Separator mit
	$BottomSeparator.queue_free()
	self.hasOffers = true

func launch():
	self.setFillAmount(1.0)
	self.launched = true

func setFillAmount(fill: float):
	self.fillAmount = fill
	if self.fillAmount <= 0.0:
		self.fillAmount = 0.0
		$TopBeam.visible = false
		$BottomBeam.visible = false
	elif self.fillAmount >= 1.0:
		self.fillAmount = 1.0
		$TopBeam.visible = false
		$BottomBeam.visible = true
		$BottomBeam.position.y = 0.0
	else:
		var viewport = get_viewport_rect().size
		$TopBeam.visible = true
		$BottomBeam.visible = true
		$TopBeam.position.y = viewport.y * self.fillAmount * 0.5
		$BottomBeam.position.y = viewport.y * (1.0 - self.fillAmount * 0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.launched:
		self.position.x = self.position.x -60 * delta
		if self.global_position.x < -200:
			# this should never happen once collection is mandatory, but we should be prepared
			self.queue_free()

func onCellCollected(cell: ShopCell):
	# guard against multiple collections + pickups in this frame – we queue the cells
	# to be freed on the next frame, collisions could still happen
	if self.collected:
		return
	self.collected = true
	
	self.upgradeSelected.emit(cell.upgrade)
	
	for child in $Cells.get_children():
		child.queue_free()
	self.queue_free()
		
	#var players = get_tree().get_nodes_in_group("Player")
	#if players.size() > 0:
		#var playership : Node2D = players[0]
		#playership.levelUpThis(cell.offerID)
