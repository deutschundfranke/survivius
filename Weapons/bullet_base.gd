extends Node2D
class_name BulletBase

signal hit_enemy(enemy)
signal hit()

var damage : float = 1
var velocity : Vector2 = Vector2(1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("ready")
	$Area2D.connect("area_entered", Callable(self, "_on_CollisionArea_area_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_CollisionArea_area_entered(area):
	if area.get_parent().is_in_group("enemies"):
		area.get_parent().take_damage(self.damage, self.velocity)
		emit_signal("hit") # signal approach
		# emit_signal("hit_enemy", area) # signal approach
		queue_free()  # Optionally, you can free the bullet after hitting the enemy
