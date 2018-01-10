extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var enemy_room = 0

onready var bullet_scene = load("Bullet.tscn")

enum EnemyState {
	INACTIVE, ATTACKING
}

var current_state = INACTIVE
var shoot_timer = 0
var SHOOT_RATE = 0.8

func _fixed_process(delta):
	var player = get_node("/root/Container/PlayerBody")
	if current_state == INACTIVE:
		if player.current_state == player.IN_ROOM && player.current_room == enemy_room:
			current_state = ATTACKING
	elif current_state == ATTACKING:
		if shoot_timer >= SHOOT_RATE:
			var bullet = bullet_scene.instance()
			bullet.set_name("EnemyBullet")
			bullet.set_pos(get_pos())
			get_parent().add_child(bullet)
			bullet.call("set_target", player.get_pos())
			shoot_timer = 0
		else:
			shoot_timer += delta

func _on_area_enter(value):
	var parent = value.get_parent()
	if parent:
		if parent.get_name().find("PlayerBullet") != -1:
			queue_free()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	get_node("Area2D").connect("area_enter", self, "_on_area_enter")
	pass
