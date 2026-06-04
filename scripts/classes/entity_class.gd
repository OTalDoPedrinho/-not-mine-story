class_name Entity
extends CharacterBody2D

@export var hp: int
@export var speed: int
@export var dmg: float
@export var mass: float

func _physics_process(delta: float) -> void:
	velocity.y+=Global.grvt*mass
