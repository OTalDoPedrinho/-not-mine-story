class_name Boss
extends Entity

@export var fases: int
@export var cur_fase = 1

var p_colidiu = false

func _physics_process(delta: float) -> void:
	super(delta)
	
	p_colidiu = false
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider and collider.name == "Player":
			p_colidiu = true
