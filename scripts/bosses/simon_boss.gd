extends Boss

enum state {idle, walk, intro, atk, hurt, die, cooldown, stage_change}
@export var cur_state: state = state.intro

@onready var anim = $"."

var detect_range = 200
var atk_detect_range = 75
var player: Node2D
var dist: float

var atk_cooldown: float

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	super(delta)
	
	dist = global_position.distance_to(player.global_position)
	
	match cur_state:
		state.idle:
			_idle()
		state.walk:
			_walk()
		state.intro:
			_intro()
		state.atk:
			_atk()
		state.hurt:
			_hurt()
		state.die:
			_die()
		state.cooldown:
			_cooldown()
		state.stage_change:
			if hp>.5*hp_max:
				_fase1()
			else:
				_fase2()
			
			cur_state = state.idle

#region State Machine
func _intro():
	pass

func _idle():
	$Sprite2D.play("idle")
	
	velocity.x = 0
	if dist > detect_range:
		cur_state = state.walk
	if dist <= detect_range:
		cur_state = state.atk

func _walk():
	var follow_dir = sign(player.global_position.x - global_position.x)
	velocity.x = follow_dir*speed
	move_and_slide()
	
	if dist < detect_range:
		cur_state = state.idle

#region Ataque
func _atk():
	match cur_fase:
		1:
			var chosen = randi_range(1, 2)
			match chosen:
				1: _atk1()
				2: _atk2()
		2:
			var chosen = randi_range(3, 4)
			match chosen:
				3: _atk3()
				4: _atk4()
	cur_state = state.cooldown

func _atk1():
	pass

func _atk2():
	pass

func _atk3():
	pass

func _atk4():
	pass

func _cooldown():
	pass
#endregion

func _hurt():
	pass

func _die():
	pass
#endregion

#region Fases
func _fase1():
	cur_fase = 1

func _fase2():
	cur_fase = 2
	speed = speed*1.4
	# novo padrão de ataqu e — adicionar ao pool de ataques
	atk_cooldown *= 0.7
#endregion
