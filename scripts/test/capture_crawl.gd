extends Node

var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer > 4.5: # 4.5s is when blue intro finishes and yellow crawl is ascending with fanfare!
		var img = get_viewport().get_texture().get_image()
		if img:
			var dir = "/Users/vincyvincent/.gemini/antigravity/scratch/lego-vader-openworld/test_screenshots"
			var file_path = dir + "/00_star_wars_opening_crawl.png"
			img.save_png(file_path)
			print("[Screenshot Saved] " + file_path)
		get_tree().quit(0)
