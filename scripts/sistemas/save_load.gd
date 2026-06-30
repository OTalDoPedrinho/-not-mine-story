extends Node

const save_location = "user://SaveFile.tres"

var SaveFileData: SaveResource = SaveResource.new()

func _ready() -> void:
	_load()

func _save():
	ResourceSaver.save(SaveFileData, save_location)

func _load() -> void:
	if FileAccess.file_exists(save_location):
		SaveFileData = ResourceLoader.load(save_location).duplicate(true)
		AudioServer.set_bus_volume_db(0, linear_to_db(SaveFileData.volume))
		if SaveFileData.fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
