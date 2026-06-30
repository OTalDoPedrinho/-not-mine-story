extends CanvasLayer

func _ready() -> void:
	visible = false
	get_tree().paused = false
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	$Opcoes/HSlider.value = SaveLoad.SaveFileData.volume
	$Opcoes/CheckButton.button_pressed = SaveLoad.SaveFileData.fullscreen

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true

func _on_button_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/sistemas/main_menu.tscn")


func _on_button_3_pressed() -> void:
	$VBoxContainer.visible = false
	$Opcoes.visible = true

func _on_check_button_button_up() -> void:
	SaveLoad.SaveFileData.fullscreen = $Opcoes/CheckButton.button_pressed
	if SaveLoad.SaveFileData.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	SaveLoad._save()

func _on_voltar_pressed() -> void:
	$VBoxContainer.visible = true
	$Opcoes.visible = false

func _on_h_slider_value_changed(value: float) -> void:
	SaveLoad.SaveFileData.volume = value
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	SaveLoad._save()
