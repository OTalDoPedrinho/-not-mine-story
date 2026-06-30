class_name StoneEnemy
extends Enemy

@export var detect_range: int
@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	speed = 0

func _physics_process(delta: float) -> void:
	super(delta)
	
	if player and global_position.distance_to(player.global_position)<=detect_range:
		await get_tree().create_timer(1.5).timeout
		speed = 15
