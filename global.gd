extends Node
var time = 100000
var bestTime = 100000
var deaths = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	# Load the best time when the node starts
	load_best_time()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
# Call this function whenever you update your time
func update_time(new_time):
	time = new_time
	
	# Check if this is a new best time (now highest is better)
	if time < bestTime:
		bestTime = time
		save_best_time()
# Save best time to a file
func save_best_time():
	var save_data = {
		"best_time": bestTime,
	}
	
	var save_file = FileAccess.open("user://game_data.save", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_data))
# Load best time from a file
func load_best_time():
	if FileAccess.file_exists("user://game_data.save"):
		var save_file = FileAccess.open("user://game_data.save", FileAccess.READ)
		var json_string = save_file.get_line()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("Error parsing save file")
			return
			
		var data = json.get_data()
		bestTime = data["best_time"]
