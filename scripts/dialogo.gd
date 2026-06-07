'''extends Node

#region variaveis
var cur_dialogue: Dictionary = {}
var cur_npc: NPC
var in_dialogue: bool = false
var text_index: int = 0

@onready var dialogue_ui = preload("res://cenas/dialogue.tscn").instantiate()
#endregion

func iniciar_dialogo(npc: NPC, json_path: String, encontro: int):
	cur_npc = npc
	_carregar_json(json_path)
	
	# Seleciona o diálogo baseado no encontro
	var encontro_key = str(encontro)
	if cur_dialogue.has("encontros") and cur_dialogue["encontros"].has(encontro_key):
		cur_dialogue = cur_dialogue["encontros"][encontro_key]
	else:
		return
	
	in_dialogue = true
	get_tree().root.add_child(dialogue_ui)
	dialogue_ui.visible = true
	_mostrar_cur_fala()

func _carregar_json(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	cur_dialogue = JSON.parse_string(text)

func _mostrar_cur_fala():
	# Agora cur_dialogue é o conteúdo do encontro (tem "falas" diretamente)
	var falas = cur_dialogue["falas"]
	var cur_fala = falas[text_index]
	
	dialogue_ui._set_name(cur_dialogue["name"])
	dialogue_ui._set_texto(cur_fala["texto"])
	
	if cur_fala.has("opcoes"):
		dialogue_ui._mostrar_opcoes(cur_fala["opcoes"])
	else:
		dialogue_ui._hide_opcoes()

func _avancar():
	var falas = cur_dialogue["falas"]
	var cur_fala = falas[text_index]
	
	if cur_fala.has("evento"):
		_executar_evento(cur_fala["evento"])
	
	if cur_fala.has("proximo"):
		text_index = buscar_indice_por_id(cur_fala["proximo"])
		_mostrar_cur_fala()
	else:
		_finalizar_dialogo()

func _choose(i: int):
	var falas = cur_dialogue["falas"]
	var cur_fala = falas[text_index]
	var opcao = cur_fala["opcoes"][i]
	
	if opcao.has("evento"):
		_executar_evento(opcao["evento"])
	
	if opcao.has("proximo"):
		text_index = buscar_indice_por_id(opcao["proximo"])
		_mostrar_cur_fala()
	else:
		_finalizar_dialogo()

func buscar_indice_por_id(id: String) -> int:
	var falas = cur_dialogue["falas"]
	for i in range(falas.size()):
		if falas[i]["id"] == id:
			return i
	
	return 0

func _executar_evento(evento: String):
	match evento:
		"_dar_picareta":
			Global.has_picaxe = true
		"_sim":
			pass
		"_nao":
			pass

func _finalizar_dialogo():
	cur_npc.encontros += 1
	in_dialogue = false
	dialogue_ui.visible = false
	text_index = 0
'''
