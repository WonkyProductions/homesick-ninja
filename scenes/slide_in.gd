extends ColorRect

var slide := true
var lerp_speed := 3.0

func _ready():
	show()
func _process(delta):
	if slide:
		
		position = position.lerp(Vector2(-1200, 0), lerp_speed * delta)
