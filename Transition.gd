extends CanvasLayer

# STORE THE SCENE PATH
var path = ""

# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func fade_to(scn_path):
	self.path = scn_path # store the scene path
	get_node("AnimationPlayer").play("fade") # play the transition animation

# PRIVATE FUNCTION. CALLED AT THE MIDDLE OF THE TRANSITION ANIMATION
func change_scene():
	if path != "":
		get_tree().change_scene(path)

func hide():
	get_node("TextureFrame").hide()

func show():
	get_node("TextureFrame").show()

func _ready():
	hide()