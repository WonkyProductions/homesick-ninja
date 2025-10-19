extends ColorRect

@export var slide := false
var lerp_speed := 5.0
var next_scene := "res://scenes/main.tscn"
var current_scene : Node
var target_position := Vector2(0, 0)
var transition_complete := false

func _ready():
	show()
	current_scene = get_tree().current_scene  # Store the current scene to manage it later

func _process(delta):
	if slide and not transition_complete:
		position = position.lerp(target_position, lerp_speed * delta)
		
		# Check if we've reached (or nearly reached) the target position
		if position.distance_to(target_position) < 1.0:
			transition_complete = true
			change_scene_smoothly()

func start_transition():
	slide = true
	# Optional: You can use the timer here if you want a delay before starting the slide
	# await get_tree().create_timer(0.5).timeout
func change_scene_smoothly():
	# Get the parent before potentially freeing anything
	var root = get_tree().root
	
	# Load the next scene resource
	var next_scene_resource = load(next_scene)
	var next_scene_instance = next_scene_resource.instantiate()
	
	# Add the new scene to the root
	root.add_child(next_scene_instance)
	
	# Remove the old scene
	current_scene.queue_free()
	
	# Make the new scene the active scene
	get_tree().current_scene = next_scene_instance
	
	# Clean up this transition object if needed
	queue_free()
