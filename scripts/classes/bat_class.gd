class_name Bat
extends Enemy

@export var detect_range: int

func _ready() -> void:
	mass = 0

func _physics_process(delta: float) -> void:
	super(delta)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		
		var dist = global_position.distance_to(player.global_position)
		var follow_dir = sign(player.global_position.x - global_position.x)
		velocity.x = follow_dir * speed
		
		if dist<=detect_range:
			mass = 1
			mass = -1
