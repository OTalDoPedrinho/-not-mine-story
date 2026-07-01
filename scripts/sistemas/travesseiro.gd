extends Node2D

var ativado = false
var player_in_range = false
var player_ref: Node = null
@export var checkpoint_id: String = "minas_01"

func _ready() -> void:
	if SaveLoad.SaveFileData.ultimo_checkpoint == checkpoint_id:
		ativado = true

func _process(delta: float) -> void:
	if player_in_range and not ativado and Input.is_action_just_pressed("act"):
		ativado = true
		_salvar(player_ref)

func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not ativado:
		player_in_range = true
		player_ref = body
		$Label.text = "W para interagir"

func _on_area_2d_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null
		$Label.text = ""

func _salvar(player: Node) -> void:
	SaveLoad.SaveFileData.hp = player.hp_max
	SaveLoad.SaveFileData.checkpoint_pos = global_position
	SaveLoad.SaveFileData.cur_room = get_tree().current_scene.scene_file_path
	SaveLoad.SaveFileData.ultimo_checkpoint = checkpoint_id
	SaveLoad.SaveFileData.has_dash = Global.has_dash
	SaveLoad.SaveFileData.has_picaxe = Global.has_picaxe
	SaveLoad.SaveFileData.mentiu_batmom = Global.mentiu_batmom
	SaveLoad.SaveFileData.toadiana_ajudou = Global.toadiana_ajudou
	SaveLoad.SaveFileData.bosses_derrotados = Global.bosses_derrotados
	SaveLoad.SaveFileData.npcs_encontrados = Global.npcs_encontrados
	$Label.text = ""
	SaveLoad._save()
