extends Node2D
class_name DamageNumber

var ySpeed : float
var xSpeed : float
var yAcc : float
var value : int
@export var label : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	self.xSpeed = -60
	self.ySpeed = -200
	self.yAcc = 0.93


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.ySpeed = self.ySpeed * self.yAcc
	if (self.ySpeed > -1):
		self.ySpeed = 0
	self.position.y += self.ySpeed * delta
	self.position.x += self.xSpeed * delta
	
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		var playership : Node2D = players[0]
		var distance : float = playership.global_position.distance_to(self.global_position)
		var speed = 250
		if (distance < 120):
			var direction = (playership.global_position - global_position).normalized()
			global_position += direction * speed * delta
		if (distance < 40):
			playership.gainEXP(self.value)
			self.queue_free()
		
	
func setValue(value : int):
	self.value = value
	self.label.text =  str(self.value)
