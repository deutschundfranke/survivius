extends Node2D
class_name Enemy

var movement: Vector2
@export var health = 3
var wiggle : float = 0
@export var tint_duration: float = 0.1

# Timer to manage the tint duration
var tint_timer: float = 0.0
# Reference to the player's sprite and its shader material
@onready var sprite: Sprite2D = $Sprite2D  # Adjust the path as needed
@onready var shader_material: ShaderMaterial = sprite.material as ShaderMaterial

signal exited_screen(who: Enemy)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_movement(speed: float, spread: float):
	self.movement = Vector2( -speed, 0)
	var angle = randf_range(-spread, spread)
	self.movement = self.movement.rotated(deg_to_rad(angle))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position += self.movement * delta
	
	self.wiggle += delta * 15
	self.rotation_degrees = cos(self.wiggle) * 12
	
	if (self.position.x < -100):
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

# Call this function to tint the player white
func tint_white():
	# Start the tint timer
	tint_timer = tint_duration
	
func die():
	self.exited_screen.emit(self)
