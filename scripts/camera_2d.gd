extends Camera2D

var shake_duration = 0.0
var shake_intensity = 0.0
var shake_timer = 0.0
var original_position = Vector2.ZERO
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = position
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $"../player".position.x > 616:
		$"../player".backupPosition.y = $"../player".position.y - 20
		$"../player".position.x = 8
		$"../player".backupPosition.x = 16
		$"../levelEditing".position.x -= 624
		$"../level".level += 1
	
	# Handle camera shake
	if shake_timer > 0:
		shake_timer -= delta
		
		# Calculate shake offset based on intensity
		var offset = Vector2()
		offset.y = rng.randf_range(-1.0, 1.0) * shake_intensity
		
		# Apply shake offset
		position = original_position + offset
		
		# Reset position when shake ends
		if shake_timer <= 0:
			position = original_position
			shake_timer = 0.0
			shake_intensity = 0.0

# Call this function to shake the camera
# duration: How long the shake lasts in seconds
# intensity: How strong the shake is (pixels)
func shake_camera(duration: float, intensity: float):
	# Only start a new shake if it's more intense than the current one
	if intensity > shake_intensity:
		shake_duration = duration
		shake_timer = duration
		shake_intensity = intensity
		original_position = position
