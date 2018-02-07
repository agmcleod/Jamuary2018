extends Node2D
var CustomLabel = preload("CustomLabel.gd")

enum {
  MOVE, SHOOT
}

var instruction_state = MOVE
var label_node
var custom_label = CustomLabel.new()

func _create_label(camera_canvas, text):
	var label = Label.new()
	label.set_text(text)
	label.set_align(Label.ALIGN_CENTER)
	camera_canvas.add_child(label)
	var size = label.get_size()
	label.position = Vector2(320 - size.x / 2, 240 - size.y / 2)
	label_node = label.get_path()

func _process(delta):
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var down = Input.is_action_pressed("ui_down")
	var up = Input.is_action_pressed("ui_up")
	var shoot = Input.is_action_pressed("shoot")

	if instruction_state == MOVE && (left || right || down || up):
		instruction_state = SHOOT
		get_node(label_node).queue_free()
		var camera_canvas = get_node("/root/Container/Camera2D/CanvasLayer")
		label_node = custom_label.create_label(camera_canvas, "Press SPACE to shoot.\nShooting can be done in 8 directions, based on your movement angle")
	elif instruction_state == SHOOT && shoot:
		get_node(label_node).queue_free()
		set_process(false)

func _ready():
	var camera_canvas = get_node("/root/Container/Camera2D/CanvasLayer")
	label_node = custom_label.create_label(camera_canvas, "Use arrow keys or WASD to move in any one of 8 directions.")
