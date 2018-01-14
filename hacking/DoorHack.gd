extends Node2D

signal done_hacking

var HACK_COOLDOWN = 3.0
var countdown = HACK_COOLDOWN

func _draw():
  draw_rect(Rect2(0, 0, 50 * (HACK_COOLDOWN - countdown) / HACK_COOLDOWN, 5), Color(0.0, 1.0, 0.0))

func _process(delta):
  countdown -= delta
  if countdown <= 0:
    emit_signal("done_hacking")
    queue_free()
  update()

func _ready():
  set_process(true)
