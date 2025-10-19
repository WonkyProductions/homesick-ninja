extends Label

var time = 00
var counting = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $"../player".velocity.x > 0 or $"../player".velocity.x < 0:
		counting = true
	if counting:
		time += delta
	if time < 10:
		text =  "0" + str(snapped(time, 00))
	else:
		text = str(snapped(time, 00))
		
	if $"../level".level == 7 or $"../level".level == 8:
		modulate = Color.WHITE
	else:
		modulate = Color.BLACK
