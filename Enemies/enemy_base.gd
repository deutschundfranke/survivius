extends Node2D
class_name EnemyBase

var movement: Vector2
var direction: float
var acceleration: Vector2
var phase:int = 1
@export var health = 5
@export var tint_duration: float = 0.1

# Timer to manage the tint duration
var tint_timer: float = 0.0
# Reference to the player's sprite and its shader material
var sprite: Sprite2D 
var shader_material: ShaderMaterial

var knockbackVector : Vector2 = Vector2(1,0)
var knockbackStrength : float = 0
var knockbackDuration : float = 0
var knockbackResistence : float = 1

signal exited_screen(who: EnemyBase)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# add knockback
	if (knockbackDuration > 0):
		knockbackDuration -= delta
		self.position += self.knockbackVector * self.knockbackStrength * delta
	else:
		self.knockbackVector = Vector2(1,0)
	
	var viewport_rect = get_viewport().get_visible_rect()
	var rect_size = viewport_rect.size
	if (self.position.x < -100 || self.position.y < -100 || self.position.y > rect_size.y + 100):
		# well off-screen
		self.exited_screen.emit(self)
		
	# check player collision
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		var playership : Node2D = players[0]
		var distance : float = playership.global_position.distance_to(self.global_position)
		if (distance < 40):
			playership.getHit(1)
			self.die()
	
		# If the tint timer is active, decrease it
	if tint_timer > 0:
		tint_timer -= delta
		
		# Update the shader tint strength
		shader_material.set_shader_parameter("tint_strength", 1.0)
		
		# When the timer runs out, revert to the original color
		if tint_timer <= 0:
			shader_material.set_shader_parameter("tint_strength", 0.0)
		
# should be in base enemy class?
func take_damage(amount):
	health -= amount
	CollectibleLayer.addDamageNumberAt(amount, self.global_position)
	self.tint_white()
	if health <= 0:
		die()
	else:
		self.knockBack(400, 0.06, Vector2(1,0))
		

func knockBack(strength : float, duration: float, direction : Vector2):
	self.knockbackStrength = maxf(self.knockbackStrength, strength * self.knockbackResistence)
	self.knockbackDuration += duration * self.knockbackResistence
	self.knockbackVector = direction

# Call this function to tint the player white
func tint_white():
	# Start the tint timer
	tint_timer = tint_duration
	
func die():
	self.exited_screen.emit(self)
