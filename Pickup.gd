extends Sprite

var pickup_timeout = 0.4
var allow_pickup = false

func _fixed_process(delta):
	if pickup_timeout >= 0:
		if !allow_pickup:
			pickup_timeout -= delta
	else:
		allow_pickup = true

func _on_area_enter(value):
	var parent = value.get_parent()
	if parent && parent.get_name() == "PlayerBody":
		on_pickup()

func _ready():
	set_fixed_process(true)
	get_node("Area2D").connect("area_enter", self, "_on_area_enter")