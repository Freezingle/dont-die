extends Control 

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_about_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/AboutMenu.tscn")	
