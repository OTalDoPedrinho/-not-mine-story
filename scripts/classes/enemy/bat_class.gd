class_name Bat_Class
extends Enemy

@export var detect_range: int
var start_y: float
var target_y: float

func _ready() -> void:
	mass = 0
	start_y = global_position.y
	target_y = start_y + 40

func _physics_process(delta: float) -> void:
	super(delta)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		var follow_dir = sign(player.global_position.x - global_position.x)
		velocity.x = follow_dir * speed
		
		if dist<=detect_range and global_position.y <= target_y:
			mass = 1
		elif dist<=detect_range and global_position.y >= target_y:
			mass = -1
		elif global_position.y >= start_y:
			velocity.y = 0
			mass = 0
