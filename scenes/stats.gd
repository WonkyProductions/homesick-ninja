extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$statsText/timeNumber.text = str(snapped(Global.time, 1))
	$statsText/deathsNumber.text = str(Global.deaths)
	$statsText/bestTimeNumber.text = str(snapped(Global.bestTime, 1))
	Global.update_time(Global.time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$statsText/timeNumber.text = str(snapped(Global.time, 1))
	$statsText/deathsNumber.text = str(Global.deaths)
	$statsText/bestTimeNumber.text = str(snapped(Global.bestTime, 1))
	
