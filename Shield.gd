extends Node2D

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = Vector2Array()
	points_arc.push_back(center)
	var colors = ColorArray([color])

	for i in range(nb_points+1):
			var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
			points_arc.push_back(center + Vector2( cos( deg2rad(angle_point) ), sin( deg2rad(angle_point) ) ) * radius)
	draw_polygon(points_arc, colors)

func _draw():
	var center = Vector2(0, 0)
	var radius = 30
	var color = Color(0.8, 0.8, 0.8, 0.5)
	draw_circle_arc_poly(center, radius, 0, 360, color)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
