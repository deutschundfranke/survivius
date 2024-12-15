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
var level_data : Array;
var enemy_events : Array[EnemyEvent]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.num_enemies_on_screen = 0
	self.spawn_cooldown = 0.0
	self.enemy_scene = load('res://Enemies/enemy1.tscn')
	self.rand = RandomNumberGenerator.new()
	self.rand.randomize()
	
	self.enemy_data = self.load_json_from_resource("res://Data/enemies.json")
	self.level_data = self.load_json_from_resource("res://Data/level1.json")
	self.parse_events(self.level_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	"""self.spawn_cooldown -= delta
	if (self.spawn_cooldown <= 0.0):
		self.spawn_cooldown += self.spawn_delay
		self.spawn_enemy()"""
	var time : float = self.find_parent("Space").find_child("Timer").time
	
	for event : EnemyEvent in self.enemy_events:
		if time > event.startTime && event.active == 0:
			event.active = 1
			print("event active")
		if event.process(delta, time):
			self.spawn_by_data(event.data, event.percentage)

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
	
	var playership : Node2D
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		playership = players[0]
			
	# do better than this
	var time : float = self.find_parent("Space").find_child("Timer").time
	var max : int = 1;
	if (time > 60): 
		max = maxi(2,max)
	if (time > 120): 
		max = maxi(3,max)
	if (time > 180): 
		max = maxi(4,max)
		spawn_delay = maxf(0.1, 0.5 - ((time - 180) / 600))
	if (time > 240): 
		max = maxi(5,max)
	if (time > 300): 
		max = maxi(6,max)
	
	self.enemy_type = self.rand.randi_range(1, max)
	
	var viewport = get_viewport_rect().size
	
	var data = self.enemy_data[self.enemy_type-1]
	self.enemy_scene = load(data.get("resource"))
	var new_enemy: EnemyUBER = self.enemy_scene.instantiate()
	
	self.hook_up_enemy(new_enemy)
	
	# initial direction and speed. should this be here?
	var spawnDirectionSpread = data.get("spawnDirectionSpread") as float
	var phases = data.get("phases")
	var phase1 = phases[0]
	var speedX = phase1.get("speedX")
	var spread = randf_range(-spawnDirectionSpread, spawnDirectionSpread)
	new_enemy.set_movement(speedX, spread)
	
	if (data.has("knockbackResistence")): new_enemy.knockbackResistence = data.get("knockbackResistence") as float
	if (data.has("damageResistence")): new_enemy.damageResistence = data.get("damageResistence") as float
	
	# Phases
	new_enemy.setPhases(phases)

	# Spawn
	var spawnYRanges : Array = data.get("spawnYRanges")
	var spawnI : int = randi_range(0,spawnYRanges.size()-1)
	var spawnRangeString = spawnYRanges[spawnI]
	var spawnYValue = self.spawnValueFromRange(spawnRangeString)
	new_enemy.position.y = viewport.y * spawnYValue
	
	if (data.has("spawnTarget")):
		if (data.get("spawnTarget") == "playerY"):
			new_enemy.position.y = playership.global_position.y
	
	if (data.has("spawnYVariation")):
		spawnI = randi_range(-(data.get("spawnYVariation") as int),(data.get("spawnYVariation") as int))
		new_enemy.position.y += spawnI
	
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
	
func spawn_by_data(data:Dictionary, percentage:float):
	self.num_enemies_on_screen += 1
	
	var playership : Node2D
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		playership = players[0]
			
	var enemy_type : int = data.get("enemyType")
	
	var viewport = get_viewport_rect().size
	
	var enemy_data = self.enemy_data[enemy_type-1]
	self.enemy_scene = load(enemy_data.get("resource"))
	var new_enemy: EnemyUBER = self.enemy_scene.instantiate()
	
	self.hook_up_enemy(new_enemy)
	
	var spawn_point : Dictionary = (data.get("spawnPoints") as Array)[0]
	
	# initial direction and speed. should this be here?
	var spawnDirectionSpread = spawn_point.get("spawnDirectionSpread") as float
	var phases = enemy_data.get("phases")
	var phase1 = phases[0]
	var speedX = phase1.get("speedX")
	var spread = randf_range(-spawnDirectionSpread, spawnDirectionSpread)
	new_enemy.set_movement(speedX, spread)
	
	if (enemy_data.has("knockbackResistence")): new_enemy.knockbackResistence = enemy_data.get("knockbackResistence") as float
	if (enemy_data.has("damageResistence")): new_enemy.damageResistence = enemy_data.get("damageResistence") as float
	
	# Phases
	new_enemy.setPhases(phases)

	var spawnXValue = 0
	var spawnYValue = 0
	
	# Spawnspawn_point
	if (spawn_point.get("spawnType") == "ranges"):
		var spawnYRanges : Array = spawn_point.get("spawnYRanges")
		var spawnI : int = randi_range(0,spawnYRanges.size()-1)
		var spawnRangeString = spawnYRanges[spawnI]
		spawnYValue = self.spawnValueFromRange(spawnRangeString)
		new_enemy.position.y = viewport.y * spawnYValue
		
		if (spawn_point.has("spawnYTarget")):
			if (spawn_point.get("spawnYTarget") == "playerY"):
				new_enemy.position.y = playership.global_position.y
		
		if (spawn_point.has("spawnYVariation")):
			spawnI = randi_range(-(spawn_point.get("spawnYVariation") as int),(spawn_point.get("spawnYVariation") as int))
			new_enemy.position.y += spawnI
		
		var spawnXRanges : Array = spawn_point.get("spawnXRanges")
		spawnI = randi_range(0,spawnXRanges.size()-1)
		spawnRangeString = spawnXRanges[spawnI]
		spawnXValue = self.spawnValueFromRange(spawnRangeString)
		
		new_enemy.position.x = viewport.x * spawnXValue
		new_enemy.position.y = viewport.y * spawnYValue
		
	elif (spawn_point.get("spawnType") == "ring"):
		var angle : float = 0
		if (spawn_point.get("spawnTransition") == "random"):
			angle = randf_range(spawn_point.get("spawnRingStart") as float, spawn_point.get("spawnRingEnd") as float)
		elif (spawn_point.get("spawnTransition") == "linear"):
			var start = spawn_point.get("spawnRingStart") as float
			var end = spawn_point.get("spawnRingEnd") as float
			angle = start + (end - start) * percentage
		if (spawn_point.get("spawnRingSpread") > 0):
			spread = spawn_point.get("spawnRingSpread") as float
			angle += randf_range(-spread, spread)
		var point : Vector2 = self.get_point_outside_viewport(angle, viewport)
		
		new_enemy.position = point
	
	# movement / speed
	if phase1.has("speedY") && phase1.get("speedY") != 0:
		var speedY = phase1.get("speedY")
		if phase1.has("speedYTarget"):
			if (phase1.get("speedYTarget") == "center"):
				if (new_enemy.position.y < viewport.y / 2):
					speedY = -speedY
		new_enemy.movement.y = speedY
	
	# health
	var health = float(data.get("healthBase"))
	new_enemy.health = health

func get_line_length_to_rectangle(angle_degrees: float, width: float, height: float) -> float:
	var cx = width / 2
	var cy = height / 2
	
	var angle_radians = deg_to_rad(angle_degrees)
	var cos_angle = cos(angle_radians)
	var sin_angle = sin(angle_radians)
	
	# Calculate t values for each edge
	var t_left = (0 - cx) / cos_angle if cos_angle != 0 else INF
	var t_right = (width - cx) / cos_angle if cos_angle != 0 else INF
	var t_top = (0 - cy) / sin_angle if sin_angle != 0 else INF
	var t_bottom = (height - cy) / sin_angle if sin_angle != 0 else INF
	
	# Check valid intersections
	var valid_t = []
	if t_left > 0:
		var y_left = cy + sin_angle * t_left
		if 0 <= y_left and y_left <= height:
			valid_t.append(t_left)
	if t_right > 0:
		var y_right = cy + sin_angle * t_right
		if 0 <= y_right and y_right <= height:
			valid_t.append(t_right)
	if t_top > 0:
		var x_top = cx + cos_angle * t_top
		if 0 <= x_top and x_top <= width:
			valid_t.append(t_top)
	if t_bottom > 0:
		var x_bottom = cx + cos_angle * t_bottom
		if 0 <= x_bottom and x_bottom <= width:
			valid_t.append(t_bottom)
	
	# Get the minimum t value
	if valid_t.size() == 0:
		return 0  # No intersection
	var t_min = valid_t.min()
	
	return t_min  # Length of the line

func get_point_outside_viewport(angle_degrees: float, viewport_size: Vector2) -> Vector2:
	# Calculate the center of the viewport
	var center = viewport_size * 0.5
	
	# Convert angle from degrees to radians
	var angle_radians = deg_to_rad(angle_degrees)
	
	# Determine the direction vector based on the angle (cos for x, sin for y)
	var direction = Vector2(cos(angle_radians), sin(angle_radians)).normalized()
	
	var length = self.get_line_length_to_rectangle(angle_degrees, viewport_size.x, viewport_size.y)
	
	direction = direction * length
	
	# Calculate the final point by moving from the center
	var new_x = center.x + direction.x
	var new_y = center.y + direction.y
	
	return Vector2(new_x, new_y)

func parse_events(data:Array):
	for item:Dictionary in data:
		var event = EnemyEvent.new()
		event.load_data(item)
		self.enemy_events.push_back(event)

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
