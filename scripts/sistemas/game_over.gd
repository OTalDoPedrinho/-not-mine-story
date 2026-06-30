extends CanvasLayer

func _ready() -> void:
	visible = false
	get_tree().paused = false
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(SaveLoad.SaveFileData.cur_room)

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/sistemas/main_menu.tscn")
