extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var velocity = Vector2(150, 150)

# Used for orb hits. Delete after 3
var hit_count = 0

func _process(delta):
	position.x += velocity.x * delta
	position.y += velocity.y * delta

func play_sound(name):
	if name == "enemy":
		$PlayerSound.play()
	elif name == "player":
		$EnemySound.play()

func set_target(target_pos):
	var current_pos = position
	var angle = atan2(target_pos.y - current_pos.y, target_pos.x - current_pos.x)
	angle = deg2rad(round(rad2deg(angle) / 45) * 45)
	velocity.x *= cos(angle)
	velocity.y *= sin(angle)

	get_node("Area2D").connect("area_entered", self, "_on_area_enter")
	return angle

func get_velocity():
	return velocity

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
		if hit_name.find("Orb") != -1:
			hit_count += 1
			if hit_count == 3:
				queue_free()
			return
		# If hit object a non enemy, and the bullet is an enemy bullet, or if it hit the player and is not a player bullet
		if (hit_name.find("Enemy") == -1 && name.find("EnemyBullet") != -1) \
			|| (hit_name != "PlayerBody" && hit_name.find("PlayerBullet") == -1 && name.find("PlayerBullet") != -1):
			queue_free()

