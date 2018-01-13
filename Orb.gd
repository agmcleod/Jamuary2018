extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var hit = false
var hit_timeout = 0
var permanently_hit = false

func _check_if_unlocked():
	var parent = get_parent()
	var hit_count = 0
	for child in parent.get_children():
		if child.get_name().find("Orb") != -1:
			if child.call("is_hit"):
				hit_count += 1

	if hit_count == 3:
		for child in parent.get_children():
			if child.get_name().find("Orb") != -1:
				child.call("set_permanently_hit")

		parent.call("on_goal_completed")

func _set_velocity_for_bullet(bullet):
	var bullet_pos = bullet.get_pos()
	var orb_pos = get_pos()
	var x_diff = abs(abs(orb_pos.x) - abs(bullet_pos.x))
	var y_diff = abs(abs(orb_pos.y) - abs(bullet_pos.y))

	var velocity = bullet.get_velocity()
	if x_diff < y_diff:
		bullet.set_velocity(velocity.x, -velocity.y)
	else:
		bullet.set_velocity(-velocity.x, velocity.y)

func _on_area_enter(body):
	if !hit && !permanently_hit:
		var body_parent = body.get_parent()
		if body_parent && body_parent.get_name().find("PlayerBullet") != -1:
			_set_velocity_for_bullet(body_parent)
			hit = true
			hit_timeout = 0.7
			var animated_sprite = get_node("AnimatedSprite")
			animated_sprite.set_animation("lit")
			_check_if_unlocked()

func _fixed_process(delta):
	if hit && !permanently_hit:
		hit_timeout -= delta
		if hit_timeout <= 0:
			hit = false
			var animated_sprite = get_node("AnimatedSprite")
			animated_sprite.set_animation("default")

func set_permanently_hit():
	permanently_hit = true

func is_hit():
	return hit

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	get_node("Area2D").connect("area_enter", self, "_on_area_enter")
	pass
