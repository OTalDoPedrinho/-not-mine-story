extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	get_tree().paused = false
	
	# Carrega configurações salvas
	$Opcoes/HSlider.value = SaveLoad.SaveFileData.volume
	$Opcoes/CheckButton.button_pressed = SaveLoad.SaveFileData.fullscreen

func mostrar_pause() -> void:
	visible = true
	get_tree().paused = true

func fechar_pause() -> void:
	visible = false
	get_tree().paused = false

func _on_button_pressed() -> void:
	# Continuar
	fechar_pause()
	queue_free()

func _on_button_2_pressed() -> void:
	# Voltar ao Main Menu
	fechar_pause()
	queue_free()
	
	# Aguarda um frame para garantir que foi removido
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://cenas/sistemas/main_menu.tscn")

func _on_button_3_pressed() -> void:
	# Abrir Opções
	$VBoxContainer.visible = false
	$Opcoes.visible = true

func _on_check_button_button_up() -> void:
	# Fullscreen
	SaveLoad.SaveFileData.fullscreen = $Opcoes/CheckButton.button_pressed
	if SaveLoad.SaveFileData.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	SaveLoad._save()

func _on_voltar_pressed() -> void:
	# Voltar das Opções
	$VBoxContainer.visible = true
	$Opcoes.visible = false

func _on_h_slider_value_changed(value: float) -> void:
	# Volume
	SaveLoad.SaveFileData.volume = value
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	SaveLoad._save()
