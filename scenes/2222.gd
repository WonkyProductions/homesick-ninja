extends ColorRect

@export var slide := false
var lerp_speed := 2.0
var next_scene := "res://YourNextScene.tscn"  # Change this to your target scene
var current_scene : Node

func _ready():
	show()
	current_scene = get_tree().current_scene  # Store the current scene to manage it later

func _process(delta):
	if slide:
		
		await get_tree().create_timer(0.5).timeout
		position = position.lerp(Vector2(-700, 0), lerp_speed * delta)
