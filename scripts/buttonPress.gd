extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	$"../../../Camera2D".shake_camera(0.3, 5)
	$buttonSprite.play("press")
	await get_tree().create_timer(.5).timeout

	hide()
	$"..".position.y = 10000
