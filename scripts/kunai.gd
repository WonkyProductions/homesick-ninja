extends Area2D

@export var speed = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += speed


func _on_body_entered(body):
	position.y = 10000
	hide()
