extends "Pickup.gd"

func on_pickup():
  Transition.show()
  Transition.fade_to("res://End.tscn", "black")
  queue_free()