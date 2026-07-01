extends CanvasLayer

func _ready() -> void:
	visible = false
	get_tree().paused = false
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if $"../Player".hp<=0:
		get_tree().paused = true
		visible = true

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(SaveLoad.SaveFileData.cur_room)
	
	$"../Player".global_position = SaveLoad.SaveFileData.checkpoint_pos
	$"../Player".hp = SaveLoad.SaveFileData.hp
	$"../Player".cur_state = $"../Player".state.idle

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/sistemas/main_menu.tscn")
