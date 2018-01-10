extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var velocity = 5
var health = 3

enum PlayerState {
	IN_ROOM, ENTERING_ROOM
}

export var CENTER_ROOM = 0
export var KEY_ROOM = 1

onready var bullet_scene = load("Bullet.tscn")

var SHOOT_COOLDOWN = 0.2

var current_state = IN_ROOM
var current_room = CENTER_ROOM
var move_camera_to = Vector2(0, 0)
var camera_start_pos = Vector2(0, 0)
var enter_room_timeout = 0
var flicker_timeout = 0
var shoot_timeout = 0
var color_mod = Color(1, 1, 1, 1)
var direction = Vector2(0, -1)

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
		if down:
			move(Vector2(0, velocity))
			direction.y = 1
		if left:
			move(Vector2(-velocity, 0))
			direction.x = -1
		if right:
			move(Vector2(velocity, 0))
			direction.x = 1

		if Input.is_action_pressed("shoot"):
			if shoot_timeout <= 0:
				shoot_timeout = SHOOT_COOLDOWN
				var bullet = bullet_scene.instance()
				bullet.set_name("PlayerBullet")
				bullet.set_pos(get_pos())
				get_parent().add_child(bullet)
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


func _on_area_enter(value):
	var parent = value.get_parent()
	var camera = get_node("/root/Container/Camera2D")
	var goto_next_room = false
	if parent:
		var name = parent.get_name()
		if name == "RightDoor":
			set_pos(Vector2(720, 240))
			move_camera_to.x = 960
			move_camera_to.y = 240
			goto_next_room = true
			current_room = KEY_ROOM
		elif name == "LeftDoor" && !parent.call("is_locked"):
			set_pos(Vector2(560, 240))
			move_camera_to.x = 320
			move_camera_to.y = 240
			goto_next_room = true
			current_room = CENTER_ROOM
		elif name.find("EnemyBullet") != -1:
			health -= 1
			flicker_timeout = 0.5
			if health == 0:
				get_tree().change_scene("res://Main.tscn")
		else:
			print(name, " not handled")

	if goto_next_room:
		current_state = ENTERING_ROOM
		camera_start_pos.x = camera.get_pos().x
		camera_start_pos.y = camera.get_pos().y

func angle_between(one, two):
	return atan2(one.y - two.y, one.x - two.x)

func set_modulate(color):
	get_node("Sprite").set_modulate(color)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Area2D").connect("area_enter", self, "_on_area_enter")
	set_fixed_process(true)
	set_modulate(color_mod)

	pass
