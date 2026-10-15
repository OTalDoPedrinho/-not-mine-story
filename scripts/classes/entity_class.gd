class_name Entity
extends CharacterBody2D

@export var hp_max: int
@export var speed: float
@export var dmg: float = 1
@export var mass: float

var hp: int

func _ready() -> void:
	hp = hp_max

func _physics_process(delta: float) -> void:
	velocity.y+=Global.grvt*mass
	
	move_and_slide()
