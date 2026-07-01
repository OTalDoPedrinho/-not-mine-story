extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	get_tree().paused = false

func mostrar_game_over() -> void:
	visible = true
	get_tree().paused = true

func _on_button_pressed() -> void:
	# Tentar Novamente
	get_tree().paused = false
	queue_free()
	
	# Aguarda um frame para garantir que foi removido
	await get_tree().process_frame
	get_tree().change_scene_to_file(SaveLoad.SaveFileData.cur_room)

func _on_button_2_pressed() -> void:
	# Voltar ao Main Menu
	get_tree().paused = false
	queue_free()
	
	# Aguarda um frame para garantir que foi removido
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://cenas/sistemas/main_menu.tscn")
