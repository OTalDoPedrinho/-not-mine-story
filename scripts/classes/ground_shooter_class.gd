class_name GroundShooter
extends Enemy

@export var shoot_range: int
@export var shoot_cooldown: float
@export var projetil_cena: PackedScene

var can_shoot: bool = true

func _physics_process(delta: float) -> void:
	super(delta)

	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = abs(global_position.x - player.global_position.x)

		if dist <= shoot_range and can_shoot:
			velocity.x = 0
			try_shoot()
		else:
			var direc = sign(player.global_position.x - global_position.x)
			velocity.x = direc * speed
	else:
		return

func try_shoot():
	if projetil_cena and can_shoot:
		can_shoot = false
		_shoot()
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true

func _shoot():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var shoot_dir = (player.global_position - global_position).normalized()
	var projetil = projetil_cena.instantiate()
	projetil.global_position = global_position + shoot_dir * 20
	projetil.velocity = shoot_dir * projetil.speed
	get_parent().add_child(projetil)
