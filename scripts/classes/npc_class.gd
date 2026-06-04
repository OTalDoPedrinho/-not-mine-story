class_name NPC
extends Area2D

@export var ensinar: String
@export var dialogo: JSON
@export var nome: String = dialogo["name"]

var player_in_range = false
var estado = 'falas'

func _ready() -> void:
	add_to_group("npc")
