extends Sprite

var mouse_over = false
var color_mod = Color(1, 1, 1, 1)
var rect
var point = Vector2(0, 0)

func _input(event):
	if !is_visible():
		return
	if event is InputEventMouseMotion || event is InputEventMouseButton:
		point.x = event.position.x
		point.y = event.position.y
		if event is InputEventMouseMotion:
			var has_point = rect.has_point(point)
			if !mouse_over && has_point:
				color_mod.a = 0.5
				set_modulate(color_mod)
				mouse_over = true
			elif mouse_over && !has_point:
				mouse_over = false
				color_mod.a = 1
				set_modulate(color_mod)
		elif event is InputEventMouseButton && rect.has_point(point):
			_on_click()

func _ready():
	var texture = get_texture()
	var width = texture.get_width()
	var height = texture.get_height()
	var global_pos = self.global_position

	rect = Rect2(global_pos.x - width / 2, global_pos.y - height / 2, width, height)

	set_process_input(true)
	pass
