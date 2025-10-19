extends Label

var level = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "level " + str(level)
	
	if $"../level".level == 7 or $"../level".level == 8  or $"../level".level == 9 or $"../level".level == 11:
		modulate = Color.WHITE
	else:
		modulate = Color.BLACK
