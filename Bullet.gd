extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var velocity = Vector2(150, 150)

func _fixed_process(delta):
	var pos = get_pos()
	pos.x += velocity.x * delta
	pos.y += velocity.y * delta
	set_pos(pos)

func set_target(target_pos):
	var current_pos = get_pos()
	current_pos.x += get_parent().get_pos().x
	current_pos.y += get_parent().get_pos().y

	# print(current_pos, target_pos, rad2deg(atan2(target_pos.y - current_pos.y, target_pos.x - current_pos.x)))

	var angle = atan2(target_pos.y - current_pos.y, target_pos.x - current_pos.x)
	angle = deg2rad(round(rad2deg(angle) / 45) * 45)
	velocity.x *= cos(angle)
	velocity.y *= sin(angle)

	get_node("Area2D").connect("area_enter", self, "_on_area_enter")

func set_velocity(x, y):
	velocity.x = x
	velocity.y = y

func _on_area_enter(value):
	var hit_parent = value.get_parent()
	var name = get_name()
	if hit_parent:
		var hit_name = hit_parent.get_name()
		if (hit_name.find("EnemyBullet") != -1 && name.find("PlayerBullet") != -1) || (hit_name.find("PlayerBullet") != -1 && name.find("EnemyBullet") != -1):
			return
		# If hit object a non enemy, and the bullet is an enemy bullet, or if it hit the player and is not a player bullet
		if (hit_name.find("Enemy") == -1 && name.find("EnemyBullet") != -1) \
			|| (hit_name != "PlayerBody" && hit_name.find("PlayerBullet") == -1 && name.find("PlayerBullet") != -1):
			print("Bullet removed against: ", hit_name)
			queue_free()

func _ready():
	set_fixed_process(true)
	pass
