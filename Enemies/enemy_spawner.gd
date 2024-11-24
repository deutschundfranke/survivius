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
var enemy_data : Array;

# Called when the node enters the scene tree for the first time.
func _ready():
	self.num_enemies_on_screen = 0
	self.spawn_cooldown = 0.0
	self.enemy_scene = load('res://Enemies/enemy1.tscn')
	self.rand = RandomNumberGenerator.new()
	self.rand.randomize()
	
	self.enemy_data = self.load_json_from_resource("res://Data/enemies.json")

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
		print ("no enemies for you!")
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
	
	var viewport = get_viewport_rect().size
	
	if (self.enemy_type <= 4):
		var data = self.enemy_data[self.enemy_type-1]
		self.enemy_scene = load(data.get("resource"))
		var new_enemy: EnemyUBER = self.enemy_scene.instantiate()
		
		# initial direction and speed. should this be here?
		var spawnDirectionSpread = data.get("spawnDirectionSpread") as float
		var phases = data.get("phases")
		var phase1 = phases[0]
		var speedX = phase1.get("speedX")
		var spread = randf_range(-spawnDirectionSpread, spawnDirectionSpread)
		new_enemy.set_movement(speedX, spread)
		
		# Phases
		new_enemy.setPhases(phases)
	
		# Spawn
		var spawnYRanges : Array = data.get("spawnYRanges")
		var spawnI = randi_range(0,spawnYRanges.size()-1)
		var spawnRangeString = spawnYRanges[spawnI]
		var spawnYValue = self.spawnValueFromRange(spawnRangeString)
		new_enemy.position.y = viewport.y * spawnYValue
		
		var spawnXRanges : Array = data.get("spawnXRanges")
		spawnI = randi_range(0,spawnXRanges.size()-1)
		spawnRangeString = spawnXRanges[spawnI]
		var spawnXValue = self.spawnValueFromRange(spawnRangeString)
		
		new_enemy.position.x = viewport.x * spawnXValue
		new_enemy.position.y = viewport.y * spawnYValue
		
		# movement / speed
		if phase1.has("speedY") && phase1.get("speedY") != 0:
			var speedY = phase1.get("speedY")
			if phase1.has("speedYTarget"):
				if (phase1.get("speedYTarget") == "center"):
					if (new_enemy.position.y < viewport.y / 2):
						speedY = -speedY
			new_enemy.movement.y = speedY
		
		# health
		var health = float(data.get("healthBase")) + float(data.get("healthPerTime")) * (time/60)
		new_enemy.health = health
		
		self.hook_up_enemy(new_enemy)
		
		# is this needed?
		"""
		var spawnSide = data.get("spawnSide")
		if (spawnSide == "right"):
		elif (spawnSide == "left"):
			new_enemy.position.x = -50
		self.hook_up_enemy(new_enemy)
		"""
		"""
	elif (self.enemy_type == 2):
		self.enemy_scene = load('res://Enemies/enemy2.tscn')
		var new_enemy: Enemy2 = self.enemy_scene.instantiate()
		new_enemy.position.x = viewport.x + 100
		var side = self.rand.randi_range(0, 1)
		new_enemy.position.y = 100
		if (side == 0):
			new_enemy.position.y = viewport.y - 100
		self.hook_up_enemy(new_enemy)
		
		
	elif (self.enemy_type == 3):
		self.enemy_scene = load('res://Enemies/enemy3.tscn')
		var new_enemy: Enemy3 = self.enemy_scene.instantiate()
		
		var newY : float  = self.rand.randi_range(50, viewport.y - 50)
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			var playership : Node2D = players[0]
			newY = playership.global_position.y + self.rand.randi_range(-150,150)
		
		new_enemy.position.x = -50
		new_enemy.position.y = newY
		self.hook_up_enemy(new_enemy)
		"""
	elif (self.enemy_type == 4):
		self.enemy_scene = load('res://Enemies/enemy4.tscn')
		var new_enemy: Enemy4 = self.enemy_scene.instantiate()
		new_enemy.position.x = viewport.x + 100
		if (self.rand.randi_range(0,1) == 1):
			new_enemy.position.y = self.rand.randf_range(100, 100 + (viewport.y / 5))
		else:
			new_enemy.position.y = self.rand.randf_range(viewport.y-100 - (viewport.y / 5), viewport.y-100)
		self.hook_up_enemy(new_enemy)

# Jonny Code for weapons JSON
func load_json_from_resource(json_path: String) -> Array:
	var file := FileAccess.open(json_path, FileAccess.READ)
	
	if file == null:
		print("Failed to open file: ", json_path)
		return []
	
	# Read the contents of the file as a string
	var json_string := file.get_as_text()
	file.close()

	# Parse the JSON string
	var json = JSON.new();
	var json_result = json.parse(json_string)

	# Check for errors
	if json_result != OK:
		print("Error parsing JSON: ", json.get_error_message)
		return []

	# Return the parsed JSON (assuming it's an array)
	return json.get_data()
	
func spawnValueFromRange(rangeString:String) -> float:
	if (rangeString.contains("_")):
		var ranges = rangeString.split("_")
		var min : float = float(ranges[0])
		var max : float = float(ranges[1])
		return randf_range(min,max)
	else:
		return float(rangeString)
	return 0
