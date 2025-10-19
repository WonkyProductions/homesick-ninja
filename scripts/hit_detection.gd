extends Area2D

var frozen = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if frozen:
		$"..".velocity = Vector2.ZERO


func _on_body_entered(body):
	if body.is_in_group("spikes"):
		$"..".deaths += 1
		$"../../die".play()
		frozen = true
		$"../playerSprite".play("hitFlash")
		await $"../playerSprite".animation_finished
		await get_tree().create_timer(0.5).timeout
		$"..".position = $"..".backupPosition
		
		frozen = false
	if body.is_in_group("spring"):
		$"../../springBounce".play()
		var launch_force = 950
		if $"../../level".level == 9:
			launch_force = 1225
		elif $"../../level".level == 6:
			launch_force = 650
			$"../../btnPress".play()
		else:
			launch_force = 950
			# Launch player in direction the spring is facing (0 = up)
		var direction = Vector2.UP.rotated(body.rotation)
		$"..".velocity = direction * launch_force

	
	if body.has_node("springSprite"):
		body.get_node("springSprite").play("bounce")


		


func _on_area_entered(area):
	if area.is_in_group("spikes"):
		$"..".deaths += 1
		$"../../die".play()
		frozen = true
		$"../playerSprite".play("hitFlash")
		await $"../playerSprite".animation_finished
		await get_tree().create_timer(0.5).timeout
		$"..".position = $"..".backupPosition
		
		frozen = false
		
	if area.is_in_group("end"):
		$"../../time".counting = false
		frozen = true
		$"../playerSprite".play("idle")
		$"../../Camera2D/slideIn2".slide = true
	
