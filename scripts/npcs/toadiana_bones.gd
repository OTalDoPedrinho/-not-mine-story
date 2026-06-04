extends NPC

func _process(delta):
	if encontros == 0:
		json_path = "res://dialogos/ToadinaBones.json"
	elif encontros == 1:
		pass
