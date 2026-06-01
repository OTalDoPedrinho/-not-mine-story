class_name StoneEnemy
extends CharacterBody2D

@export var detect_range: int
@export var hp: int
@export var speed: int
@export var dmg: int
@onready var player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	
	if player:
		await get_tree().create_timer(1.5).timeout
		_follow()

func _follow():
	if not player.squat:
		
		var dist = global_position.distance_to(player.global_position)
		
		if dist<=detect_range:
			var direc = sign(player.global_position.x - global_position.x)
			velocity.x = direc * speed
