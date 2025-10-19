extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	play("run")
	$"../ninjaRunning".play("run")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
