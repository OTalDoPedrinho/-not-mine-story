class_name Entity
extends CharacterBody2D

@export var hp_max: int
@export var speed: int
@export var dmg: float
@export var mass: float

var hp

func _physics_process(delta: float) -> void:
	velocity.y+=Global.grvt*mass
	
	move_and_slide()
