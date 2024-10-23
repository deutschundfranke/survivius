extends Node2D
class_name BulletBase

signal hit_enemy(enemy)
signal hit()
signal die_signal()

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
		var will_die : bool = true
		if ("isBeam" in self && self.isBeam):
			will_die = false
		if ("numberPenetrate" in self && self.numberPenetrate > 0):
			self.numberPenetrate -= 1
			will_die = false
		if ("areaOfEffect" in self && self.areaOfEffect > 0):
			self.onAreaOfEffect()
			will_die = false
		if (will_die):
			self.die()  # Optionally, you can free the bullet after hitting the enemy
		
func die():
	emit_signal("die_signal", self)
	queue_free()
	
func onAreaOfEffect():
	pass
