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
		var speed = playership.collection_speed
		var global_speed = playership.collection_global_speed
		if (distance < playership.collection_radius):
			var direction = (playership.global_position - global_position).normalized()
			global_position += direction * speed * delta
		if (global_speed > 0):
			var direction = (playership.global_position - global_position).normalized()
			global_position += direction * global_speed * delta
		if (distance < 40):
			playership.gainEXP(self.value)
			self.queue_free()
		
	
func setValue(value : int):
	self.value = value
	self.label.text =  str(self.value)
	var saturation = value / 10.0
	var hue = 0.3 - minf(0.3,value / 20.0)
	hue = 0.166
	var alpha = 1
	var v = 1.0
	var color = Color.from_hsv(hue, saturation, v, alpha)
	self.label.modulate = color
	var scale = 1 + (value / 10.0)
	self.label.scale = Vector2(scale, scale)
