extends Node2D

@export var damage_number : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	self.damage_number = load("res://Collectibles/DamageNumber.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	self.get_parent().add_child(new_number)
