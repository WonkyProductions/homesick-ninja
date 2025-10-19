extends ColorRect

@export var slide := false
var lerp_speed := 5.0
var next_scene := "res://YourNextScene.tscn"  # Change this to your target scene
var current_scene : Node

func _ready():
	current_scene = get_tree().current_scene  # Store the current scene to manage it later

func _process(delta):
	if slide:
		if $"../menuMusic":
			$"../menuMusic".volume_db -= 0.1
		await get_tree().create_timer(0.5).timeout
		position = position.lerp(Vector2.ZERO, lerp_speed * delta)

		# If the ColorRect is close to (0, 0), begin the scene switch
		if position.distance_to(Vector2.ZERO) < 1.0:
			switch_scene()

func switch_scene():
	# Hide the current scene smoothly (or fade out)
	current_scene.queue_free()  # This will remove the current scene

	# Preload the next scene
	var next_scene_instance = preload("res://scenes/main.tscn").instantiate()

	# Add the next scene in the background (without showing it yet)
	get_tree().current_scene = next_scene_instance
	get_tree().root.add_child(next_scene_instance)
	
	# Optionally, use a delay or animation before showing the new scene (fade in, etc)
	# You could also add a fade-in effect here if desired
	next_scene_instance.show()
	
	# Switch to the next scene and clean up
	slide = false  # Disable further sliding
	get_tree().current_scene = next_scene_instance
