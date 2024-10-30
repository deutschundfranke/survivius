# DPSMeter.gd
extends Node

# Variables for tracking
var total_damage : float = 0.0           # Total damage dealt by the weapon
var recent_damage : Array = []           # List of hit timestamps with damage values
const TIME_WINDOW : float = 60.0         # 60-second window for DPS calculation

# Called when a hit is made
func add_damage(damage_amount: float):
	# 1. Add damage to the total
	total_damage += damage_amount
	
	# 2. Add damage with timestamp to the recent damage list
	recent_damage.append({"damage": damage_amount, "timestamp": Time.get_ticks_msec() / 1000.0})
	
	# 3. Remove outdated hits from recent_damage
	_cleanup_old_hits()

# Cleanup function to remove hits older than TIME_WINDOW
func _cleanup_old_hits():
	recent_damage = recent_damage.filter(is_recent)

func is_recent(hit):
	var current_time = Time.get_ticks_msec() / 1000.0
	return hit["timestamp"] > current_time - TIME_WINDOW

# Calculate DPS over the last 60 seconds
func calculate_dps() -> float:
	# Cleanup old hits first
	_cleanup_old_hits()
	
	# Sum up recent damage values within the TIME_WINDOW
	var damage_sum = 0.0
	for hit in recent_damage:
		damage_sum += hit["damage"]
		
	return damage_sum / TIME_WINDOW  # DPS over last 60 seconds

# Debug print function (optional)
func print_stats():
	print("Total Damage:", total_damage)
	print("DPS (last 60s):", calculate_dps())
