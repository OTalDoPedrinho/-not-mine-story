extends Boss

func _physics_process(delta: float) -> void:
	super(delta)
	
	match cur_state:
		state.idle:
			velocity.x = 0
			if velocity.x != 0:
				cur_state = state.walk
		state.walk:
			pass
		state.intro:
			pass
		state.atk:
			pass
		state.hurt:
			pass
		state.die:
			pass
		state.cooldown:
			pass
		state.stage_change:
			if hp>.5*hp_max:
				_fase1()
			else:
				_fase2()

func _fase1():
	pass

func _fase2():
	pass
