extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var key_card_ui_scene = load("KeyCardUI.tscn")
onready var hack_tool_ui_scene = load("HackToolUI.tscn")
onready var door_hack_scene = load("DoorHack.tscn")

var velocity = 5
var health = 3
var has_hacktool = false
var hacktool_connected = false

enum PlayerState {
	IN_ROOM, ENTERING_ROOM, HACKING
}

enum HackTargetType {
	DOOR, PANEL
}

export var CENTER_ROOM = 0
export var KEY_ROOM = 1
export var ORB_ROOM = 2
export var TOP_ROOM = 3

onready var bullet_scene = load("Bullet.tscn")

var SHOOT_COOLDOWN = 0.2

var current_state = IN_ROOM
var current_room = CENTER_ROOM
var current_hack_type = DOOR
var move_camera_to = Vector2(0, 0)
var camera_start_pos = Vector2(0, 0)
var enter_room_timeout = 0
var flicker_timeout = 0
var shoot_timeout = 0
var color_mod = Color(1, 1, 1, 1)
var direction = Vector2(0, -1)
var key_cards = []
var hacking_door_path = NodePath("")

func _add_hacking_ui():
	var camera_canvas = get_node("/root/Container/Camera2D/CanvasLayer")
	var label = Label.new()
	label.set_text("Press E to hack")
	label.set_name("hack_label")
	label.set_align(Label.ALIGN_CENTER)
	camera_canvas.add_child(label)
	var size = label.get_size()
	label.set_pos(Vector2(320 - size.x / 2, 240 - size.y / 2))

func _get_current_room():
	var rooms = get_tree().get_nodes_in_group("rooms")
	for room in rooms:
		if room.room_id == current_room:
			return room

func _fixed_process(delta):
	if current_state == IN_ROOM:

		var left = Input.is_action_pressed("ui_left")
		var right = Input.is_action_pressed("ui_right")
		var down = Input.is_action_pressed("ui_down")
		var up = Input.is_action_pressed("ui_up")

		if left || right || down || up:
			direction.x = 0
			direction.y = 0

		if up:
			move(Vector2(0, -velocity))
			direction.y = -1
			set_rotd(0)
		if down:
			move(Vector2(0, velocity))
			direction.y = 1
			set_rotd(180)
		if left:
			move(Vector2(-velocity, 0))
			direction.x = -1
			set_rotd(90)
		if right:
			move(Vector2(velocity, 0))
			direction.x = 1
			set_rotd(270)
		if hacktool_connected && Input.is_action_pressed("hack") && current_state == IN_ROOM:
			current_state = HACKING
			if current_hack_type == DOOR:
				var door_hack = door_hack_scene.instance()
				door_hack.connect("done_hacking", self, "_on_done_hacking_door")
				door_hack.set_pos(get_pos())
				get_parent().add_child(door_hack)

		if current_state == IN_ROOM && Input.is_action_pressed("shoot"):
			if shoot_timeout <= 0:
				shoot_timeout = SHOOT_COOLDOWN
				var bullet = bullet_scene.instance()
				bullet.set_name("PlayerBullet")
				var current_room = _get_current_room()
				var current_room_pos = current_room.get_pos()
				var player_pos = get_pos()
				player_pos.x -= current_room_pos.x
				player_pos.y -= current_room_pos.y
				bullet.set_pos(player_pos)
				current_room.add_child(bullet)
				var pos = get_pos()
				bullet.call("set_velocity", 450, 450)
				bullet.call("set_target", Vector2(pos.x + direction.x, pos.y + direction.y))

	elif current_state == ENTERING_ROOM:
		enter_room_timeout += delta
		var camera = get_node("/root/Container/Camera2D")
		camera.set_pos(camera_start_pos.linear_interpolate(move_camera_to, enter_room_timeout / 0.5))
		if enter_room_timeout >= 0.5:
			enter_room_timeout = 0
			current_state = IN_ROOM

	if flicker_timeout > 0:
		flicker_timeout -= delta
		if color_mod.a == 0.3 || flicker_timeout <= 0:
			color_mod.a = 1
		else:
			color_mod.a = 0.3
		set_modulate(color_mod)

	if shoot_timeout > 0:
		shoot_timeout -= delta

func _on_done_hacking_door():
	current_state = IN_ROOM
	get_node(hacking_door_path).call("set_locked", false)
	_cleanup_hacking_ui_state()
	hacking_door_path = NodePath("")

func _move_camera_to_room(room):
	var room_pos = room.get_pos()
	move_camera_to.x = room_pos.x + 320
	move_camera_to.y = room_pos.y + 240

func _move_to_next_room(door):
	var room = door.get_node(door.exit_room)
	_move_camera_to_room(room)
	current_room = room.room_id
	set_pos(door.exit_pos)
	room.call("on_player_enter")

func _on_area_enter(body):
	var parent = body.get_parent()
	var camera = get_node("/root/Container/Camera2D")
	var goto_next_room = false
	if parent:
		var door = parent
		var name = door.get_name()
		if name.find("Door") != -1:
			if !door.call("is_locked") || door.can_open(self):
				_move_to_next_room(door)
				goto_next_room = true
			elif door.hackable && has_hacktool && !hacktool_connected:
				hacktool_connected = true
				current_hack_type = DOOR
				hacking_door_path = door.get_path()
				_add_hacking_ui()
		elif name.find("EnemyBullet") != -1:
			health -= 1
			flicker_timeout = 0.5
			if health == 0:
				get_tree().change_scene("res://Main.tscn")
		# else:
			# print("Unhandled collision: ", name)

	if goto_next_room:
		current_state = ENTERING_ROOM
		camera_start_pos.x = camera.get_pos().x
		camera_start_pos.y = camera.get_pos().y

func _cleanup_hacking_ui_state():
	hacktool_connected = false
	get_node("/root/Container/Camera2D/CanvasLayer/hack_label").queue_free()

func _on_area_exit(body):
	var parent = body.get_parent()
	if parent.get_name().find("Door") != -1 && hacktool_connected:
		_cleanup_hacking_ui_state()

func angle_between(one, two):
	return atan2(one.y - two.y, one.x - two.x)

func give_keycard(name):
	var camera_canvas = get_node("/root/Container/Camera2D/CanvasLayer")
	var card = key_card_ui_scene.instance()
	card.set_animation(name)
	card.set_pos(Vector2(40, 30))
	card.set_name(name + "_key_card_ui")
	camera_canvas.add_child(card)
	key_cards.append(name)

func give_hacktool():
	has_hacktool = true
	var hack_tool = hack_tool_ui_scene.instance()
	hack_tool.set_pos(Vector2(40, 30))
	var camera_canvas = get_node("/root/Container/Camera2D/CanvasLayer")
	camera_canvas.add_child(hack_tool)

func has_keycard(name):
	return key_cards.has(name)

func set_modulate(color):
	get_node("Sprite").set_modulate(color)

func use_keycard(name):
	key_cards.remove(key_cards.find(name))
	var camera_canvas = get_node("/root/Container/Camera2D/CanvasLayer")
	camera_canvas.get_node(name + "_key_card_ui").queue_free()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Area2D").connect("area_enter", self, "_on_area_enter")
	get_node("Area2D").connect("area_exit", self, "_on_area_exit")
	set_fixed_process(true)
	set_modulate(color_mod)

	pass
