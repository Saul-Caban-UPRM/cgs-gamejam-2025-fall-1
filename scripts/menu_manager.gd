extends CanvasLayer

##########################################
#Retry Menu buttons
func _ready() -> void:
	if(GlobalScript.MenuStates == "Retry"):
		$StartingMenu.hide()
		$RetryMenu.show()
	else:
		$StartingMenu.show()
		$RetryMenu.hide()
func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_exit_game_pressed() -> void:
	get_tree().quit()
##############################################


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_how_to_play_pressed() -> void:
	pass # Replace with function body.
