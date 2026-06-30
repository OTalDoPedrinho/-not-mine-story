extends CanvasLayer

func _ready() -> void:
	$"Main/Carregar Jogo".disabled = not FileAccess.file_exists("user://SaveFile.tres")
	$Opcoes.visible = false
	$Opcoes/HSlider.value = SaveLoad.SaveFileData.volume
	$Opcoes/CheckButton.button_pressed = SaveLoad.SaveFileData.fullscreen
	AudioServer.set_bus_volume_db(0, linear_to_db(SaveLoad.SaveFileData.volume))  # ← falta isso

#region Main
func _on_button_pressed() -> void:
	SaveLoad.SaveFileData = SaveResource.new()
	get_tree().change_scene_to_file("res://cenas/salas/cena_01.tscn")

func _on_button_2_pressed() -> void:
	SaveLoad._load()
	get_tree().change_scene_to_file(SaveLoad.SaveFileData.cur_room)

func _on_button_3_pressed() -> void:
	$Main.visible = false
	$Opcoes.visible = true

func _on_button_4_pressed() -> void:
	get_tree().quit()
#endregion

#DisplayServer.window_set_mode

#region Opcoes
func _on_check_button_button_up() -> void:
	SaveLoad.SaveFileData.fullscreen = $Opcoes/CheckButton.button_pressed
	if SaveLoad.SaveFileData.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	SaveLoad._save()

func _on_voltar_pressed() -> void:
	$Main.visible = true
	$Opcoes.visible = false

func _on_h_slider_value_changed(value: float) -> void:
	SaveLoad.SaveFileData.volume = value
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	SaveLoad._save()
