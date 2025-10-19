extends Sprite2D

var kunai_timer := 0.0  # Accumulates time in seconds

func _ready():
	# Hide the original kunai template
	$kunai.visible = false
	
func _process(delta):
	kunai_timer += delta
	if kunai_timer >= 2.0:
		kunai_timer = 0  # Reset timer
		spawn_kunai()

func spawn_kunai():
	# Create a duplicate of the kunai child node
	var new_kunai = $kunai.duplicate()
	new_kunai.visible = true  # Make it visible
	
	# You may want to set a different position for the spawned kunai
	# For example, offset it from the current sprite's position
	new_kunai.position = Vector2(0.667, 0)  # Position relative to this sprite
	
	# Add the new kunai as a child of this sprite
	add_child(new_kunai)
	
	# If the kunai needs to move independently, you might want to 
	# add it to a different parent instead, like:
	# get_parent().add_child(new_kunai)
	# new_kunai.global_position = global_position
