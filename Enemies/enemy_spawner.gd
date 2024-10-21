extends Node2D
class_name EnemySpawner

@export var spawn_delay: float = 2.0
@export var max_enemies: int = 5
@export var enemy_speed: float = 200.0
@export var enemy_spread: float = 15.0
@export var enemy_type: int = 1

var spawn_cooldown: float = 0.0
var enemy_scene: PackedScene
var num_enemies_on_screen: int
var rand: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	self.num_enemies_on_screen = 0
	self.spawn_cooldown = 0.0
	self.enemy_scene = load('res://Enemies/enemy1.tscn')
	self.rand = RandomNumberGenerator.new()
	self.rand.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.spawn_cooldown -= delta
	if (self.spawn_cooldown <= 0.0):
		self.spawn_cooldown += self.spawn_delay
		self.spawn_enemy()

func on_enemy_exited(enemy: EnemyBase):
	enemy.queue_free()
	self.num_enemies_on_screen -= 1
	
func hook_up_enemy(enemy: EnemyBase):
	enemy.exited_screen.connect(self.on_enemy_exited)
	self.find_parent("Space").add_child(enemy)
	
func spawn_enemy():
	if (self.num_enemies_on_screen >= self.max_enemies):
		# print ("no enemies for you!")
		return
	self.num_enemies_on_screen += 1
	
	# do better than this
	var time : float = self.find_parent("Space").find_child("Timer").time
	var max : int = 1;
	if (time > 60): 
		max = 2
	if (time > 120): 
		max = 3
	if (time > 180): 
		max = 4
		spawn_delay = maxf(0.1, 0.5 - ((time - 180) / 600))
	
	self.enemy_type = self.rand.randi_range(1, max)
	
	if (self.enemy_type == 1):
		self.enemy_scene = load('res://Enemies/enemy1.tscn')
		var new_enemy: Enemy1 = self.enemy_scene.instantiate()
		new_enemy.set_movement(self.enemy_speed, self.enemy_spread)
		var viewport = get_viewport_rect().size
		new_enemy.position.x = viewport.x + 100
		new_enemy.position.y = self.rand.randf_range(100, viewport.y-100)
		self.hook_up_enemy(new_enemy)
		
	elif (self.enemy_type == 2):
		self.enemy_scene = load('res://Enemies/enemy2.tscn')
		var new_enemy: Enemy2 = self.enemy_scene.instantiate()
		var viewport = get_viewport_rect().size
		new_enemy.position.x = viewport.x + 100
		var side = self.rand.randi_range(0, 1)
		new_enemy.position.y = 100
		if (side == 0):
			new_enemy.position.y = viewport.y - 100
		self.hook_up_enemy(new_enemy)
		
	elif (self.enemy_type == 3):
		self.enemy_scene = load('res://Enemies/enemy3.tscn')
		var new_enemy: Enemy3 = self.enemy_scene.instantiate()
		var viewport = get_viewport_rect().size
		
		var newY : float  = self.rand.randi_range(50, viewport.y - 50)
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			var playership : Node2D = players[0]
			newY = playership.global_position.y + self.rand.randi_range(-150,150)
		
		new_enemy.position.x = -50
		new_enemy.position.y = newY
		self.hook_up_enemy(new_enemy)
		
	elif (self.enemy_type == 4):
		self.enemy_scene = load('res://Enemies/enemy4.tscn')
		var new_enemy: Enemy4 = self.enemy_scene.instantiate()
		var viewport = get_viewport_rect().size
		new_enemy.position.x = viewport.x + 100
		if (self.rand.randi_range(0,1) == 1):
			new_enemy.position.y = self.rand.randf_range(100, 100 + (viewport.y / 5))
		else:
			new_enemy.position.y = self.rand.randf_range(viewport.y-100 - (viewport.y / 5), viewport.y-100)
		self.hook_up_enemy(new_enemy)
