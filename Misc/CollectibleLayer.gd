extends Node2D

@export var damage_number : PackedScene
@export var merge_effect : PackedScene
var instances : Array
var check_timer = 0.0
var check_interval = 1.0  # Check every 1 second
const GRID_SIZE = 64
const MERGE_DISTANCE = 48
var collectible_grid = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.damage_number = load("res://Collectibles/DamageNumber.tscn")
	self.merge_effect = load("res://Collectibles/CollectibleMerge.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Recalculate the quadtree's grid after movement
	collectible_grid = {}
	for collectible in instances:
		update_grid(collectible)
	
	check_timer += delta
	if check_timer >= check_interval:
		check_timer = 0.0
		check_for_merges()
	pass
	
func addDamageNumberAt(value:int, position:Vector2):
	#print(value)
	if (value < 1): 
		value = 1
	var new_number: DamageNumber = self.damage_number.instantiate()
	new_number.setValue(value)
	new_number.position = position
	# new_enemy.position.y = self.rand.randf_range(100, viewport.y-100)
	# new_enemy.exited_screen.connect(self.on_enemy_exited)
	#self.add_child(new_number)
	self.get_parent().add_child(new_number)
	
	self.instances.push_back(new_number)
	
func removeMe(number):
	self.instances.erase(number)

func update_grid(collectible):
	if !is_instance_valid(collectible): return
	var cell_x = int(collectible.position.x / GRID_SIZE)
	var cell_y = int(collectible.position.y / GRID_SIZE)
	var cell_key = Vector2(cell_x, cell_y)

	if cell_key not in collectible_grid:
		collectible_grid[cell_key] = []
	collectible_grid[cell_key].append(collectible)
	
func check_for_merges():
	for cell_key in collectible_grid.keys():
		var collectibles = collectible_grid[cell_key]
		for i in range(collectibles.size()):
			for j in range(i + 1, collectibles.size()):
				if collectibles[i].position.distance_to(collectibles[j].position) < MERGE_DISTANCE:
					merge_collectibles(collectibles[i], collectibles[j])
					
func merge_collectibles(c1:DamageNumber, c2:DamageNumber):
	var value = c1.value + c2.value
	c1.setValue(value)
	c2.die()
	
	var merge: CollectibleMerge = self.merge_effect.instantiate()
	merge.position = c1.global_position
	self.get_parent().add_child(merge)
