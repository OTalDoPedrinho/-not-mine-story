class_name StoneEnemy
extends Enemy

@export var detect_range: int
@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	speed = 0

func _physics_process(delta: float) -> void:
	super(delta)
	
	if player and not player.squat:
		await get_tree().create_timer(1.5).timeout
		speed = 30
