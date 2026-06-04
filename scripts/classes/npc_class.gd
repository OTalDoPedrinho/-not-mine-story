class_name NPC
extends Area2D

@export var ensinar: String = ""
@export var json_path: String = ""
@export var npc_name: String = "NPC"

var player_in_range = false
var encontros = 0

func _ready():
	add_to_group("npc")
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)

func _on_player_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_player_exited(body):
	if body.name == "Player":
		player_in_range = false

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("act"):
		Dialogo.iniciar_dialogo(self, json_path, encontros)
