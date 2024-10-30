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
		for weapon:WeaponBase in playership.weapons:
			text += weapon.getDPSOutput()+"\n"
	$Label.text = text
