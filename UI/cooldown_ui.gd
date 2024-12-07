extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Player")
	var text = ""
	if players.size() > 0:
		var playership : Node2D = players[0]
		var i:int = 1;
		for weapon:WeaponBase in playership.weapons:
			self.updateWeaponCooldown(i, weapon.getCooldownPercentage())
			self.updateWeaponLevels(i, weapon.getUpgradeLevels())
			i += 1
	
func updateWeaponCooldown(index:int, percentage:float):
	var node_name = "CoolDownMeter" + str(index)
	var node = get_node(node_name)
	node.set_cooldown_percentage(percentage)

func updateWeaponLevels(index:int, levels:Array):
	var node_name = "CoolDownMeter" + str(index)
	var node = get_node(node_name)
	node.set_upgrade_levels(levels)
