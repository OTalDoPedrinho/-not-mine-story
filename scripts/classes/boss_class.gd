class_name Boss
extends Entity

enum state {idle, walk, intro, atk, hurt, die, cooldown, stage_change}

@export var fases = 2
@export var cur_state: state = state.intro

func _physics_process(delta: float) -> void:
	super(delta)
