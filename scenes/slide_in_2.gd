extends ColorRect

var slide := false
var lerp_speed := 3.0
var target_position := Vector2(-316, -370)
var next_scene_path := "res://scenes/stats.tscn"

func _ready():
	show()
	modulate.a = 1.0

func _process(delta):
	if slide:
		if $"../../music":
			$"../../music".volume_db -= 0.1
		position = position.lerp(target_position, lerp_speed * delta)
		if position.distance_to(target_position) < 1.0:
			change_scene()

func start_transition():
	slide = true

func change_scene():
	# Simply change to the next scene
	get_tree().change_scene_to_file(next_scene_path)
