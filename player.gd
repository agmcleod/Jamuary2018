extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var key_card_ui_scene = load("KeyCardUI.tscn")
onready var hack_tool_ui_scene = load("HackToolUI.tscn")
onready var door_hack_scene = load("DoorHack.tscn")
onready var hot_wire_scene = load("HotWire.tscn")
onready var bullet_scene = load("Bullet.tscn")

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
	label.rect_position = Vector2(320 - size.x / 2, 240 - size.y / 2)

func _get_current_room():
	var rooms = get_tree().get_nodes_in_group("rooms")
	for room in rooms:
		if room.room_id == current_room:
			return room

func _on_hotwire_finished(positions):
	if positions["left"] == "green" && positions["center"] == "red" && positions["right"] == "blue":
		var panel = get_node("/root/Container/HackRoom/Panel")
		panel.call("unlock")
		for enemy in get_tree().get_nodes_in_group("shielded_enemies"):
			enemy.call("remove_shield")

		hacktool_connected = false
		current_state = IN_ROOM

		get_node("/root/Container/Camera2D/CanvasLayer/HotWire").queue_free()

func _physics_process(delta):
	if current_state == IN_ROOM:
		var left = Input.is_action_pressed("ui_left")
		var right = Input.is_action_pressed("ui_right")
		var down = Input.is_action_pressed("ui_down")
		var up = Input.is_action_pressed("ui_up")

		if left || right || down || up:
			direction.x = 0
			direction.y = 0

		if left && up:
			rotation_degrees = 315
		elif left && down:
			rotation_degrees = 225
		elif left:
			rotation_degrees = 270
		elif right && up:
			rotation_degrees = 45
		elif right && down:
			rotation_degrees = 135
		elif right:
			rotation_degrees = 90
		elif up:
			rotation_degrees = 0
		elif down:
			rotation_degrees = 180

		if up:
			move_and_collide(Vector2(0, -velocity))
			direction.y = -1
		if down:
			move_and_collide(Vector2(0, velocity))
			direction.y = 1
		if left:
			move_and_collide(Vector2(-velocity, 0))
			direction.x = -1
		if right:
			move_and_collide(Vector2(velocity, 0))
			direction.x = 1
		if hacktool_connected && Input.is_action_pressed("hack") && current_state == IN_ROOM:
			current_state = HACKING
			_cleanup_hacking_ui_state()
			if current_hack_type == DOOR:
				var door_hack = door_hack_scene.instance()
				door_hack.connect("done_hacking", self, "_on_done_door_hacking")
				door_hack.position = Vector2(position.x, position.y)
				door_hack.position.y += 30
				get_parent().add_child(door_hack)
			elif current_hack_type == PANEL:
				var hot_wire = hot_wire_scene.instance()
				var camera_canvas = get_node("/root/Container/Camera2D/CanvasLayer")
				hot_wire.position = Vector2(320, 380)
				hot_wire.set_name("HotWire")
				hot_wire.connect("finished", self, "_on_hotwire_finished")
				camera_canvas.add_child(hot_wire)

		if current_state == IN_ROOM && Input.is_action_pressed("shoot"):
			if shoot_timeout <= 0:
				shoot_timeout = SHOOT_COOLDOWN
				var bullet = bullet_scene.instance()
				bullet.set_name("PlayerBullet")
				var current_room = _get_current_room()
				var current_room_pos = current_room.rect_position
				var player_pos = Vector2(position.x, position.y)
				player_pos.x -= current_room_pos.x
				player_pos.y -= current_room_pos.y
				bullet.position = player_pos
				current_room.add_child(bullet)
				bullet.call("play_sound", "player")
				bullet.call("set_velocity", 450, 450)
				bullet.call("set_target", Vector2(player_pos.x + direction.x, player_pos.y + direction.y))

	elif current_state == ENTERING_ROOM:
		enter_room_timeout += delta
		var camera = get_node("/root/Container/Camera2D")
		camera.position = camera_start_pos.linear_interpolate(move_camera_to, enter_room_timeout / 0.5)
		camera.align()
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

func _connect_hack_tool_for_type(type):
	hacktool_connected = true
	current_hack_type = type

func _on_done_door_hacking():
	get_node(hacking_door_path).call("set_locked", false)
	hacking_door_path = NodePath("")
	hacktool_connected = false
	current_state = IN_ROOM

func _move_camera_to_room(room):
	var room_pos = room.get_rect().position
	move_camera_to.x = room_pos.x + 320
	move_camera_to.y = room_pos.y + 240

func _move_to_next_room(door):
	var room = door.get_node(door.exit_room)
	_move_camera_to_room(room)
	current_room = room.room_id
	position = door.exit_pos
	room.call("on_player_enter")

func _on_body_enter(body):
	if body.get_name().find("Panel") != -1 && body.call("is_locked"):
		_connect_hack_tool_for_type(PANEL)
		_add_hacking_ui()

func _on_body_exit(body):
	if body.get_name().find("Panel") != -1 && hacktool_connected:
		_cleanup_hacking_ui_state()

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
				_connect_hack_tool_for_type(DOOR)
				hacking_door_path = door.get_path()
				_add_hacking_ui()
		elif name.find("EnemyBullet") != -1:
			health -= 1
			get_node("/root/Container/HitHurtSound").play()
			flicker_timeout = 0.5
			for node in get_tree().get_nodes_in_group("health_bars"):
				node.queue_free()
				break
			if health == 0:
				Transition.show()
				Transition.fade_to("res://Main.tscn", "red")
		# else:
		# 	print("Unhandled collision: ", name)

	if goto_next_room:
		current_state = ENTERING_ROOM
		camera_start_pos.x = camera.position.x
		camera_start_pos.y = camera.position.y
		get_node("/root/Container/DoorSound").play()

func _cleanup_hacking_ui_state():
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
	card.position = Vector2(40, 30)
	card.set_name(name + "_key_card_ui")
	camera_canvas.add_child(card)
	key_cards.append(name)

func give_hacktool():
	has_hacktool = true
	var hack_tool = hack_tool_ui_scene.instance()
	hack_tool.position = Vector2(40, 30)
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
	get_node("Area2D").connect("area_entered", self, "_on_area_enter")
	get_node("Area2D").connect("area_exited", self, "_on_area_exit")
	set_physics_process(true)
	set_modulate(color_mod)
	get_node("Area2D").connect("body_entered", self, "_on_body_enter")
	get_node("Area2D").connect("body_exited", self, "_on_body_exit")

	get_node("/root/Container/Camera2D").make_current()

	pass
