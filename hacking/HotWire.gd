extends Sprite

signal finished(positions)

var CustomLabel = preload("../CustomLabel.gd")

var from_selected_color = ""
var to_selected_side = ""

var positions = {
	"left": "red", "center": "green", "right": "blue"
}

enum {
	SHOW_WIRE_CLICK, SHOW_CONNECTOR_CLICK, NONE
}

var current_instruction = SHOW_WIRE_CLICK
var instruction_label
var label_node = CustomLabel.new()

func _play_click_sound():
	get_node("SamplePlayer2D").play("Click")

func _show_wire():
	positions[to_selected_side] = from_selected_color
	get_node(from_selected_color + to_selected_side).show()
	from_selected_color = ""
	to_selected_side = ""
	if positions["left"] != "" && positions["center"] != "" && positions["right"] != "":
		emit_signal("finished", positions)

func _on_top_clicked(color):
	_play_click_sound()
	if positions["left"] != color && positions["center"] != color && positions["right"] != color:
		from_selected_color = color
		if to_selected_side != "":
			_show_wire()

func _on_bottom_clicked(side):
	_play_click_sound()
	if current_instruction == SHOW_CONNECTOR_CLICK:
		get_node(instruction_label).queue_free()
		current_instruction = NONE
	if positions[side] == "":
		to_selected_side = side
		if from_selected_color != "":
			_show_wire()

func _on_wire_clear(color):
	_play_click_sound()
	if positions["left"] == color:
		positions["left"] = ""
	elif positions["center"] == color:
		positions["center"] = ""
	elif positions["right"] == color:
		positions["right"] = ""

	if current_instruction == SHOW_WIRE_CLICK:
		current_instruction = SHOW_CONNECTOR_CLICK
		get_node(instruction_label).queue_free()
		var camera_canvas = get_node("/root/Container/Camera2D/CanvasLayer")
		instruction_label = label_node.create_label(camera_canvas, "Click a free top node to select which wire colour.\nClick a free bottom node to connect the wire to that end.\nFind the right configuration to disable the shields")

func _ready():
	get_node("redtopconnector").connect("clicked", self, "_on_top_clicked")
	get_node("greentopconnector").connect("clicked", self, "_on_top_clicked")
	get_node("bluetopconnector").connect("clicked", self, "_on_top_clicked")
	get_node("leftbottomconnector").connect("clicked", self, "_on_bottom_clicked")
	get_node("centerbottomconnector").connect("clicked", self, "_on_bottom_clicked")
	get_node("rightbottomconnector").connect("clicked", self, "_on_bottom_clicked")

	for wire in get_tree().get_nodes_in_group("wires"):
		wire.connect("clicked", self, "_on_wire_clear")

	var camera_canvas = get_node("/root/Container/Camera2D/CanvasLayer")
	instruction_label = label_node.create_label(camera_canvas, "Click a red/green/blue wire to remove it.")

	pass
