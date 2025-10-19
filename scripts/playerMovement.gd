extends CharacterBody2D

# Movement constants
@export var SPEED: float = 350.0
@export var ACCELERATION: float = 3000.0
@export var FRICTION: float = 2000.0
@export var MAX_FALL_SPEED: float = 800.0
@export var GRAVITY: float = 2000.0
@export var JUMP_FORCE: float = -600.0
@export var JUMP_CUT_MULTIPLIER: float = 0.4  # When releasing jump button early
@export var WALL_SLIDE_SPEED: float = 120.0
@export var WALL_JUMP_PUSH: float = 400.0
var deaths = 0
# Dash constants
@export var DASH_SPEED: float = 600.0
@export var DASH_DURATION: float = 0.25
@export var DASH_COOLDOWN: float = 0.4
@export var DASH_LENGTH: float = 150.0  # How far the dash travels
@export var DASH_COUNT: int = 1  # How many dashes before needing to reset
@export var VERTICAL_DASH_MULTIPLIER: float = 0.7  # Vertical dash speed multiplier

# Dash trail constants
@export var DASH_TRAIL_COUNT: int = 4  # Number of clones to create
@export var DASH_TRAIL_DURATION: float = 0.3  # How long clones last
@export var DASH_TRAIL_MIN_ALPHA: float = 0.1  # Minimum alpha value for the first clone

# Timing constants
@export var COYOTE_TIME: float = 0.12  # Time after leaving ground that you can still jump
@export var JUMP_BUFFER_TIME: float = 0.12  # Time to buffer a jump when pressing before hitting ground

# Animation variables
@onready var animated_sprite = $playerSprite  # Your AnimatedSprite2D node

# Timers for movement mechanics
var coyote_timer = 0.0
var jump_buffer_timer = 0.0

# Dash variables
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var is_dashing = false
var dash_direction = Vector2.RIGHT
var can_dash = true
var dashes_left = 0
var dash_clone_positions = []  # Store positions for clones
var dash_start_position = Vector2.ZERO

var has_double_jump = false  # Celeste has a single mid-air jump
var backupPosition = position

func _ready():
	# Initialize dashes
	dashes_left = DASH_COUNT

func _physics_process(delta):
	if not $hitDetection.frozen:
		# Update timers
		update_timers(delta)
		
		# Handle dash mechanics
		if handle_dash(delta):
			# If currently dashing, skip other movement processing
			move_and_slide()
			enforce_x_boundary()
			update_animations()
			return
		
		# Apply gravity
		apply_gravity(delta)
		
		# Handle jump mechanics
		handle_jumping(delta)
		
		# Handle horizontal movement
		handle_horizontal_movement(delta)
		
		# Wall sliding
		handle_wall_slide()
		
		# Execute movement
		move_and_slide()
		
		# Enforce X boundary (don't allow going past X=0)
		enforce_x_boundary()
		
		# Post-movement checks
		handle_landing()
		
		# Update animations
		update_animations()

func enforce_x_boundary():
	# Don't allow player to go past X=0 (into negative X coordinates)
	if position.x < 12:
		position.x = 12
		# Also stop horizontal velocity if hitting this boundary
		if velocity.x < 0:
			velocity.x = 0

func update_timers(delta):
	# Update all timing mechanics
	if coyote_timer > 0:
		coyote_timer -= delta
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		
	if dash_timer > 0:
		dash_timer -= delta
		
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	elif not can_dash:
		can_dash = true

func handle_dash(delta):
	# Start a new dash when button is pressed
	if Input.is_action_just_pressed("dash") and dashes_left > 0 and dash_cooldown_timer <= 0:
		# Get dash direction based on input
		$"../dash".play()
		dash_direction = Vector2.ZERO
		
		# Determine dash direction including diagonal dashes
		if Input.is_action_pressed("left"):
			# Check if we're already at or near the boundary
			if position.x <= 5:  # Small buffer to prevent dashing left at boundary
				dash_direction.x = 0  # Don't allow leftward dash component
			else:
				dash_direction.x = -1
		elif Input.is_action_pressed("right"):
			dash_direction.x = 1
		else:
			# Default to current facing direction if no horizontal input
			if animated_sprite and animated_sprite.flip_h:
				# Check if we're at boundary before dashing left
				if position.x <= 5:
					dash_direction.x = 0
				else:
					dash_direction.x = -1
			else:
				dash_direction.x = 1
			
		# Add vertical component if pressing up or down

			
		# Normalize diagonal movement (only if we have any direction)
		if dash_direction.length() > 0:
			dash_direction = dash_direction.normalized()
		else:
			# If we have no direction (e.g., tried to dash left at boundary), default to right
			dash_direction = Vector2.RIGHT
		
		# Start dash
		is_dashing = true
		dash_timer = DASH_DURATION
		dashes_left -= 1
		dash_cooldown_timer = DASH_COOLDOWN
		
		# Apply dash velocity
		velocity = dash_direction * DASH_SPEED
		
		# Store the start position of the dash
		dash_start_position = position
		
		# Calculate positions for all the clones
		calculate_dash_trail_positions()
		
		return true
		
	# Handle ongoing dash
	if is_dashing:
		if dash_timer <= 0 or is_on_wall():
			# End dash
			is_dashing = false
			velocity *= 0.5  # Maintain some momentum
		else:
			# Keep dashing
			velocity = dash_direction * DASH_SPEED
			
			# Calculate how far through the dash we are (0 to 1)
			var dash_progress = 1.0 - (dash_timer / DASH_DURATION)
			
			# Spawn all clones at their calculated positions based on dash progress
			spawn_dash_trail(dash_progress)
				
			return true
			
	return false

# Calculate the positions for all dash trail clones at the start of a dash
func calculate_dash_trail_positions():
	dash_clone_positions.clear()
	
	# Estimate the end position of the dash
	var dash_end_position = dash_start_position + dash_direction * DASH_LENGTH
	
	# Create positions spaced evenly along the dash path
	for i in range(DASH_TRAIL_COUNT):
		var t = float(i + 1) / float(DASH_TRAIL_COUNT + 1)  # +1 to avoid placing at the exact start/end
		var clone_pos = dash_start_position.lerp(dash_end_position, t)
		dash_clone_positions.append(clone_pos)

# Spawn all dash trail clones at appropriate times
func spawn_dash_trail(dash_progress):
	# We want to spawn each clone exactly once, when we reach its position
	# Calculate which clone should be spawned at this point in the dash
	var clone_index = floor(dash_progress * (DASH_TRAIL_COUNT + 1)) - 1
	
	# Only spawn if we've reached a valid clone index and haven't spawned it yet
	if clone_index >= 0 and clone_index < DASH_TRAIL_COUNT:
		# Get the spawn position from our pre-calculated array
		var spawn_position = dash_clone_positions[clone_index]
		
		# Spawn the clone
		spawn_dash_clone(clone_index, spawn_position)

# Function to spawn a single dash clone at a specific position
func spawn_dash_clone(index, spawn_position):
	if not animated_sprite:
		return
	
	# Create a new sprite that looks identical to the player sprite
	var clone = Sprite2D.new()
	clone.texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	clone.flip_h = animated_sprite.flip_h
	
	# REVERSED: Darkest clone is the furthest away (first in the trail)
	# Highest index is furthest from player (start of dash), should be darkest
	var alpha = lerp(DASH_TRAIL_MIN_ALPHA, 0.7, float(index) / float(DASH_TRAIL_COUNT - 1))
	clone.modulate = Color(0, 0, 0, alpha)  # Black color with varying alpha
	
	# Position the clone at the calculated position
	clone.global_position = spawn_position
	clone.scale = animated_sprite.scale
	clone.z_index = animated_sprite.z_index - 1  # Place behind the player
	
	# Add to scene
	get_parent().add_child(clone)

	# Set up fade-out effect
	var tween = get_tree().create_tween()
	tween.tween_property(clone, "modulate:a", 0.0, DASH_TRAIL_DURATION)
	tween.tween_callback(clone.queue_free)
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		# Ensure we don't fall too fast
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	elif coyote_timer <= 0:
		# Reset coyote time when on floor
		coyote_timer = COYOTE_TIME

func handle_jumping(delta):
	# Start coyote timer when leaving the ground
	if is_on_floor():
		has_double_jump = false  # Reset double jump when on ground
		dashes_left = DASH_COUNT  # Reset dashes when on ground
	elif was_on_floor() and not is_on_floor():
		coyote_timer = COYOTE_TIME
		
	# Buffer jump input
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
		
	# Execute jump if on ground or in coyote time
	if jump_buffer_timer > 0 and (is_on_floor() or coyote_timer > 0):
		execute_jump()
		$"../jump".play()
		jump_buffer_timer = 0
		coyote_timer = 0
	# Double jump in air
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and has_double_jump:
		execute_jump()
		has_double_jump = false
		dashes_left = DASH_COUNT  # Reset dash after double jump like in Celeste
		
	# Variable jump height by cutting velocity when button released
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

func execute_jump():
	velocity.y = JUMP_FORCE

func handle_horizontal_movement(delta):
	var direction = Input.get_axis("left", "right")
	
	# Prevent movement left if at X=0 boundary
	if direction < 0 and position.x <= 0:
		direction = 0
	
	if direction != 0:
		# Accelerate
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		# Flip sprite based on direction
		if animated_sprite:
			animated_sprite.flip_h = direction < 0
	else:
		# Apply friction
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func handle_wall_slide():
	var is_near_wall = is_on_wall()
	var moving_into_wall = false
	
	if is_near_wall:
		var wall_normal = get_wall_normal()
		moving_into_wall = (wall_normal.x < 0 and Input.is_action_pressed("right")) or \
			(wall_normal.x > 0 and Input.is_action_pressed("left"))
	
	# Wall slide
	if is_near_wall and not is_on_floor() and moving_into_wall:
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
		dashes_left = DASH_COUNT  # Reset dash when wall sliding like in Celeste
		
		# Wall jump
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_FORCE * 0.9  # Slightly weaker than normal jump
			velocity.x = get_wall_normal().x * WALL_JUMP_PUSH
			$"../wallJump".play()

func handle_landing():
	if is_on_floor() and not was_on_floor():
		pass

func update_animations():
	if not animated_sprite:
		return
		
	# Determine the current animation state
	var anim_name = "idle"
	
	if is_dashing:
		pass
	elif is_on_wall() and not is_on_floor() and (
		(get_wall_normal().x < 0 and Input.is_action_pressed("right")) or
		(get_wall_normal().x > 0 and Input.is_action_pressed("left"))
	):
		anim_name = "slide"  # Wall slide animation
	elif not is_on_floor():
		# Always use jump animation when in air (removed fall animation)
		anim_name = "jump"
	elif abs(velocity.x) > 10:  # Small threshold to avoid flickering
		anim_name = "run"
	
	# Play the animation if it's not already playing
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

# Helper function to check if we were on the floor last frame
func was_on_floor():
	return get_slide_collision_count() > 0 and get_slide_collision(0).get_normal().y < 0
