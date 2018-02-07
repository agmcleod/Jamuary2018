extends AnimatedSprite

var pickup_timeout = 0.4
var allow_pickup = false

func _process(delta):
	if pickup_timeout >= 0:
		if !allow_pickup:
			pickup_timeout -= delta
	else:
		allow_pickup = true

func _on_area_enter(value):
	var parent = value.get_parent()
	if parent && parent.get_name() == "PlayerBody":
		get_node("/root/Container/PickupSound").play()
		on_pickup()

func _ready():
	get_node("Area2D").connect("area_entered", self, "_on_area_enter")