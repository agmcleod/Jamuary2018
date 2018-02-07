extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var enemy_room = 0
export var shielded = false

onready var bullet_scene = load("Bullet.tscn")
onready var shield_scene = load("Shield.tscn")

enum EnemyState {
	INACTIVE, ATTACKING
}

var current_state = INACTIVE
var shoot_timer = 0
var SHOOT_RATE = 1.4

func start_attacking():
	current_state = ATTACKING

func remove_shield():
	shielded = false
	get_node("shield").queue_free()
	remove_from_group("shielded_enemies")

func _physics_process(delta):
	if current_state == ATTACKING:
		if shoot_timer >= SHOOT_RATE:
			var bullet = bullet_scene.instance()
			bullet.set_name("EnemyBullet")
			bullet.position = Vector2(position.x, position.y)
			get_parent().add_child(bullet)
			bullet.call("play_sound", "enemy")
			var player = get_node("/root/Container/PlayerBody")
			var target_pos = Vector2(player.position.x, player.position.y)
			target_pos.x -= get_parent().get_rect().position.x
			target_pos.y -= get_parent().get_rect().position.y
			var angle = bullet.call("set_target", target_pos)
			get_node("Turret").rotation = angle - deg2rad(45)
			shoot_timer = 0
		else:
			shoot_timer += delta

func _on_area_enter(value):
	var hit_by_entity = value.get_parent()
	if hit_by_entity:
		if hit_by_entity.get_name().find("PlayerBullet") != -1:
			if !shielded:
				get_node("/root/Container/HitHurtSound").play()
				queue_free()
				get_parent().call("on_enemy_removed")
			else:
				$HitShieldSound.play()


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_physics_process(true)
	get_node("Area2D").connect("area_entered", self, "_on_area_enter")
	if shielded:
		var shield = shield_scene.instance()
		shield.set_name("shield")
		add_child(shield)
		add_to_group("shielded_enemies")
	pass
