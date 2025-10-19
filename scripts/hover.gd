extends Label

var initial_scale = scale
var target_scale = scale + Vector2(0.1, 0.1)
var grow_scale = target_scale # How big it grows on hover
var lerp_speed = 10.0

var original_position
var pressed_offset = Vector2(0, 10)

func _ready():
	initial_scale = scale
	target_scale = initial_scale
	original_position = position

func _process(delta):
	scale = scale.lerp(target_scale, delta * lerp_speed)

func _on_play_button_mouse_entered():
	target_scale = grow_scale

func _on_play_button_mouse_exited():
	target_scale = initial_scale

func _on_play_button_button_down():
	position = original_position + pressed_offset

func _on_play_button_button_up():
	position = original_position


func _on_play_button_pressed():
	$"../slideIn".slide = true


func _on_options_button_pressed():
	pass # Replace with function body.


func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scripts/menu.tscn")


func _on_retry_pressed():
	$"../slideIn2".slide = true
