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
var SHOOT_RATE = 1.4

func start_attacking():
	current_state = ATTACKING

func _fixed_process(delta):
	if current_state == ATTACKING:
		if shoot_timer >= SHOOT_RATE:
			var bullet = bullet_scene.instance()
			bullet.set_name("EnemyBullet")
			bullet.set_pos(get_pos())
			get_parent().add_child(bullet)
			var player = get_node("/root/Container/PlayerBody")
			bullet.call("set_target", player.get_pos())
			shoot_timer = 0
		else:
			shoot_timer += delta

func _on_area_enter(value):
	var hit_by_entity = value.get_parent()
	if hit_by_entity:
		if hit_by_entity.get_name().find("PlayerBullet") != -1:
			queue_free()
			get_parent().call("on_enemy_removed")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	get_node("Area2D").connect("area_enter", self, "_on_area_enter")
	pass
