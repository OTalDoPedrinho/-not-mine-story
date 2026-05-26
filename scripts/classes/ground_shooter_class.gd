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
		var dist = global_position.ditance_to(player.global_position)

		if dist<=shoot_range and can_shoot:
			velocity.x = 0
			try_shoot()
		else:
			var direc = sign(global_position.x - player.global_position.x)
			velocity.x = direc*speed
	else:
		return

func try_shoot():
	if projetil_cena:
		can_shoot = false
		shoot()
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true
