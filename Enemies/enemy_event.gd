extends Node
class_name EnemyEvent

var data : Dictionary
var active : int = 0
var startTime : float = 0
var endTime : float = 0
var percentage : float = 0
var spawnCount : int = 0
var spawnCountMax : int = 0
var spawnDelay : float = 0
var spawnTimer : float = 0
var spawnDelayEase : float = 1.0
var enemyType : int = 1
var _totalSpawnTime = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta: float, time:float) -> bool:
	if (self.active == 1):
		if (self.spawnCount > 0):
			self.spawnTimer -= delta
			self.percentage = (time - self.startTime) / (self.endTime - self.startTime)
			if (self.spawnTimer <= 0):
				self.spawnCount -= 1
				#var spawnTime = self.getNextSpawnTime(self.spawnCountMax - self.spawnCount)
				#var delay = spawnTime - self._totalSpawnTime
				var delay = self.getNextSpawnTime(self.spawnCountMax - self.spawnCount)
				self.spawnTimer = delay
				print(delay)
				self._totalSpawnTime += delay
				# self.spawn()
				return true
		else:
			self.active = 2
	return false

func getNextDelay() -> float:
	var t = float(self.spawnCountMax - self.spawnCount) / self.spawnCountMax
	var delay = pow(t, self.spawnDelayEase) * self.spawnDelay

	print("T: " + str(t) + " Delay: " + str(delay))
	self._totalSpawnTime += delay
	return delay

func getNextSpawnTime(spawn_index: int) -> float:
	var total_duration = self.endTime - self.startTime
	var t = float(spawn_index) / (self.spawnCountMax)  # Progress from 0 to 1
	
	# Apply easing based on spawnDelayEase
	#var eased_t = self.circular_ease(t, self.spawnDelayEase)  # Adjust the progress based on easing
	var d_start = self.spawnDelay * self.spawnDelayEase
	var d_end = self.spawnDelay * 2 - d_start
	var weight = t * t * (3 - 2 * t)
	var delay = d_start + (d_end - d_start) * weight
	
	# Calculate the time at which this spawn occurs
	# var spawn_time = eased_t * total_duration
	return delay

func circular_ease(t: float, ease_factor: float) -> float:
	if ease_factor == 1.0:
		return t  # Linear case
	
	# Blend between linear and circular easing
	var adjusted_t = pow(t, 1.0 / ease_factor)
	return adjusted_t * (1.0 - sqrt(1.0 - t * t)) + (1.0 - adjusted_t) * t


func load_data(data:Dictionary):
	self.data = data
	self.startTime = data.get("startTime") as float
	self.enemyType = data.get("enemyType") as int
	self.spawnCount = data.get("spawnCount") as int
	self.spawnCountMax = self.spawnCount
	self.spawnDelay = data.get("spawnDelay") as float
	self.spawnDelayEase = data.get("spawnDelayEase") as float
	self.endTime = self.startTime + self.spawnCount * self.spawnDelay

#func spawn() -> void:
	#(self.find_parent("Space").find_child("EnemySpawner") as EnemySpawner).spawn_by_data(self.data)
