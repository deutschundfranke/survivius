extends Node2D
class_name EnemyBase

var movement: Vector2
var direction: float
var acceleration: Vector2
var speed: Vector2
var phase:int = 1
@export var health = 15
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
	var area: Area2D = self.find_child("Area2D")
	if (area):
		#print("I can haz area")
		area.body_entered.connect(onBodyEntered)
	
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
	if (self.position.x < -200 || self.position.y < -100 || 
		self.position.y > rect_size.y + 100 || self.position.x > rect_size.x + 300 ):
		# well off-screen
		self.exited_screen.emit(self)
		
	# check player collision
	#var players = get_tree().get_nodes_in_group("Player")
	#if players.size() > 0:
		#var playership : Node2D = players[0]
		#var distance : float = playership.global_position.distance_to(self.global_position)
		#if (distance < 40):
			#playership.getHit(1)
			#self.die()
	
	# If the tint timer is active, decrease it
	if tint_timer > 0:
		tint_timer -= delta
		
		# Update the shader tint strength
		shader_material.set_shader_parameter("tint_strength", 1.0)
		
		# When the timer runs out, revert to the original color
		if tint_timer <= 0:
			shader_material.set_shader_parameter("tint_strength", 0.0)
		
# should be in base enemy class?
func take_damage(amount, knockbackStrength:int, bulletVelocity : Vector2):
	# overkill damage value is capped at health
	amount = minf(amount, health)
	health -= amount
	CollectibleLayer.addDamageNumberAt(amount, self.global_position)
	self.tint_white()
	if health <= 0:
		die()
	else:
		var duration : float = 0.06
		if (knockbackStrength > 400):
			duration = (knockbackStrength / 400) * 0.06
			knockbackStrength = 400 + knockbackStrength / 10
		self.knockBack(knockbackStrength, duration, bulletVelocity.normalized())
		

func knockBack(strength : float, duration: float, direction : Vector2):
	self.knockbackStrength = maxf(self.knockbackStrength, strength * self.knockbackResistence)
	self.knockbackDuration += duration * self.knockbackResistence
	self.knockbackVector = direction

# Call this function to tint the player white
func tint_white():
	# Start the tint timer
	tint_timer = tint_duration
	
func die():
	var scene : PackedScene = load('res://Enemies/Explosion.tscn')
	var explosion : Explosion = scene.instantiate()
	explosion.global_position = self.global_position
	self.find_parent("Space").add_child(explosion)
	
	self.exited_screen.emit(self)

func onBodyEntered(body: PhysicsBody2D):
	print("something hit")
	if body.is_in_group("Player"):
		var player: Player = body as Player
		if (player):
			player.getHit(1)
			self.die()
