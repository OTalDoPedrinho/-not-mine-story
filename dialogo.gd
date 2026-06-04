extends Node

#region variaveis
var cur_dialogue: Dictionary = {}
var cur_npc: NPC
var in_dialogue: bool = false
var text_index: int = 0

@onready var dialogue_ui = preload("res://cenas/dialogue.tscn").instantiate()
#endregion

func iniciar_dialogo(npc: NPC, dialogue: Dictionary):
	cur_npc = npc
	_carregar_json(json_path)
	in_dialogue = true
	get_tree().root.add_child(dialogue_ui)
	dialogue_ui.visible = true
	_mostrar_cur_fala()

func _carregar_json(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	cur_dialogue = JSON.parse_string(text)

func _mostrar_cur_fala():
	var falas = cur_dialogue["falas"]
	var cur_fala = falas[text_index]
	
	dialogue_ui.set_name(cur_dialogue["name"])
	dialogue_ui.set_texto(cur_fala["texto"])
	
	if cur_fala.has("opcoes"):
		_mostar_opcoes(cur_fala["opcoes"])
	else:
		_hide_opcoes()

func _avancar():
	var falas = cur_dialogue["falas"]
	var cur_fala = falas[text_index]
	
	if cur_fala.has("evento"):
		_executar_evento(cur_fala["evento"])
