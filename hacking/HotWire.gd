extends Sprite

var from_selected_color = ""
var to_selected_side = ""

var positions = {
	"left": "red", "center": "green", "right": "blue"
}

func _show_wire():
	positions[to_selected_side] = from_selected_color
	get_node(from_selected_color + to_selected_side).show()
	from_selected_color = ""
	to_selected_side = ""

func _on_top_clicked(color):
	if positions["left"] != color && positions["center"] != color && positions["right"] != color:
		from_selected_color = color
		if to_selected_side != "":
			_show_wire()

func _on_bottom_clicked(side):
	if positions[side] == "":
		to_selected_side = side
		if from_selected_color != "":
			_show_wire()

func _on_clear(color):
	if positions["left"] == color:
		positions["left"] = ""
	elif positions["center"] == color:
		positions["center"] = ""
	elif positions["right"] == color:
		positions["right"] = ""

func _ready():
	get_node("redtopconnector").connect("clicked", self, "_on_top_clicked")
	get_node("greentopconnector").connect("clicked", self, "_on_top_clicked")
	get_node("bluetopconnector").connect("clicked", self, "_on_top_clicked")
	get_node("leftbottomconnector").connect("clicked", self, "_on_bottom_clicked")
	get_node("centerbottomconnector").connect("clicked", self, "_on_bottom_clicked")
	get_node("rightbottomconnector").connect("clicked", self, "_on_bottom_clicked")

	for wire in get_tree().get_nodes_in_group("wires"):
		wire.connect("clicked", self, "_on_clear")

	pass
