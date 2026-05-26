class_name Follower
extends Enemy

@export var detect_range: int

func _physics_process(delta: float) -> void:
	super(delta)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		
		if dist<=detect_range:
			var direc = sign(player.global_position.x - global_position.x)
			velocity.x = direc * speed
		else:
			velocity.x = speed * dir
