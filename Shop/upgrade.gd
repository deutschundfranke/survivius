class_name Upgrade

var target: String
var subtarget: String
var feature: String
var name: String
var color: Color
var label: String
# var icon
# var weight: float

func _init(t: String, f: String, n: String, c: Color, l: String, st = ""):
	target = t
	feature = f
	name = n
	color = c
	label = l
	subtarget = st
