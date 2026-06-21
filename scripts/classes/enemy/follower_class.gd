class_name Follower
extends Enemy

@export var detect_range: int = 75

func _physics_process(delta: float) -> void:
	super(delta)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		
		if dist<=detect_range:
			var follow_dir = sign(player.global_position.x - global_position.x)
			dir = follow_dir
			move_and_slide()
