extends Node2D
class_name EnemySpawner

@export var spawn_delay: float = 2.0
@export var max_enemies: int = 5
@export var enemy_speed: float = 200.0
@export var enemy_spread: float = 15.0

var spawn_cooldown: float = 0.0
var enemy_scene: PackedScene
var num_enemies_on_screen: int
var rand: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	self.num_enemies_on_screen = 0
	self.spawn_cooldown = 0.0
	self.enemy_scene = load('res://Enemies/enemy.tscn')
	self.rand = RandomNumberGenerator.new()
	self.rand.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.spawn_cooldown -= delta
	if (self.spawn_cooldown <= 0.0):
		self.spawn_cooldown += self.spawn_delay
		self.spawn_enemy()

func on_enemy_exited(enemy: Enemy):
	enemy.queue_free()
	self.num_enemies_on_screen -= 1
	
func spawn_enemy():
	if (self.num_enemies_on_screen >= self.max_enemies):
		# print ("no enemies for you!")
		return
	self.num_enemies_on_screen += 1
	var new_enemy: Enemy = self.enemy_scene.instantiate()
	new_enemy.set_movement(self.enemy_speed, self.enemy_spread)
	var viewport = get_viewport_rect().size
	new_enemy.position.x = viewport.x + 100
	new_enemy.position.y = self.rand.randf_range(100, viewport.y-100)
	new_enemy.exited_screen.connect(self.on_enemy_exited)
	self.find_parent("Space").add_child(new_enemy)
