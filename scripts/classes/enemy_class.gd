class_name Enemy
extends CharacterBody2D

@export var hp: int
@export var speed: int
@export var dmg: int

var direc = [1, -1]
var dir = direc.pick_random()

func _physics_process(delta: float) -> void:
	# Reseta colisão a cada frame
	var p_collidiu = false
	
	# Aplica gravidade
	velocity.y += Global.grvt
	
	# Movimento horizontal
	velocity.x = speed * dir
	
	move_and_slide()
	
	# Verifica colisão com player
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider and collider.name == "Player":
			p_collidiu = true
	
	# Vira na parede se não colidiu com player
	if is_on_wall() and not p_collidiu:
		dir = -dir

func tomar_dano():
	hp -= 1
	if hp <= 0:
		queue_free()
