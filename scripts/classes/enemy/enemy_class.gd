class_name Enemy
extends Entity

var direc = [1, -1]
var dir = direc.pick_random()
var p_colidiu = false

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	super(delta)
	
	p_colidiu = false
	
	# Movimento horizontal
	velocity.x = speed * dir
	
	move_and_slide()
	
	# Verifica colisão com player
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider and collider.name == "Player":
			p_colidiu = true
	
	# Vira na parede se não colidiu com player
	if is_on_wall() and not p_colidiu:
		dir = -dir

func tomar_dano(dano: float, attacker_pos: Vector2):
		hp -= dano
		if hp <= 0:
			queue_free()
