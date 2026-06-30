extends Node2D

var ativado = false

@export var checkpoint_id: String = "minas_01"

func _ready() -> void:
	if SaveLoad.SaveFileData.cur_room == checkpoint_id:
		ativado = true
		$Sprite2D.play("ativo")

func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not ativado:
		ativado = true
		_salvar(body)

func _salvar(player: Node) -> void:
	SaveLoad.SaveFileData.hp = player.hp_max
	SaveLoad.SaveFileData.checkpoint_pos = global_position
	SaveLoad.SaveFileData.cur_room = checkpoint_id
	SaveLoad.SaveFileData.has_dash = Global.has_dash
	SaveLoad.SaveFileData.has_picaxe = Global.has_picaxe
	SaveLoad.SaveFileData.mentiu_batmom = Global.mentiu_batmom
	SaveLoad.SaveFileData.toadiana_ajudou = Global.toadiana_ajudou
	SaveLoad.SaveFileData.bosses_derrotados = Global.bosses_derrotados
	SaveLoad.SaveFileData.npcs_encontrados = Global.npcs_encontrados
	SaveLoad._save()
