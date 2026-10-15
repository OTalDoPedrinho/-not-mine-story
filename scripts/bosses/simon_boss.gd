extends Boss

enum state {idle, walk, intro, atk, hurt, die, cooldown, stage_change}
@export var cur_state: state = state.intro

var detect_range = 200
var atk_detect_range = 75
var player: Node2D
var dist: float
var atk_cooldown: float = 2.0
var follow_dir
var can_attack: bool = true

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	super(delta)
	
	if player:
		dist = global_position.distance_to(player.global_position)
		follow_dir = sign(player.global_position.x - global_position.x)
	
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
			# ← ADICIONADO: proteção para hp_max = 0
			if hp_max <= 0:
				hp_max = hp
			
			if hp > .5 * hp_max:
				_fase1()
			else:
				_fase2()
			
			cur_state = state.idle

#region State Machine
func _intro():
	#$Sprite2D.play("intro")
	await get_tree().create_timer(1.0).timeout
	cur_state = state.idle

func _idle():
	$Sprite2D.play("idle")
	
	velocity.x = 0
	if dist > detect_range:
		cur_state = state.walk
	elif dist <= detect_range and can_attack:  # ← ADICIONADO: só ataca se pode
		cur_state = state.atk

func _walk():
	velocity.x = follow_dir*speed
	move_and_slide()
	
	if dist < detect_range:
		cur_state = state.idle

#region Ataque
func _atk():
	# ← ADICIONADO: verifica se pode atacar
	if not can_attack:
		cur_state = state.cooldown
		return
	
	can_attack = false  # ← ADICIONADO: bloqueia novo ataque até o cooldown
	
	match cur_fase:
		1:
			var chosen
			
			if dist<=150:
				chosen = 1
			else:
				chosen = 2
			match chosen:
				1: await _atk1()  # ← ADICIONADO await
				2: await _atk2()  # ← ADICIONADO await'
		2:
			var chosen = randi_range(3, 4)
			match chosen:
				3: await _atk3()  # ← ADICIONADO await
				4: await _atk4()  # ← ADICIONADO await
	
	cur_state = state.cooldown

#region Ataques 
func _atk1():
	velocity = Vector2.ZERO
	
	#$Sprite2D.play("atk01_prep")
	await get_tree().create_timer(0.3).timeout
	#$Sprite2D.play("atk01")
	$MeeleeArea/CollisionShape2D.disabled = false
	await get_tree().create_timer(0.25).timeout
	$MeeleeArea/CollisionShape2D.disabled = true
	
	#$Sprite2D.play("idle")
	cur_state = state.cooldown

func _atk2():
	velocity = Vector2.ZERO
	
	if follow_dir == 0:
		follow_dir = 1
	
	#$Sprite2D.play("atk02_prep")
	await get_tree().create_timer(0.3).timeout
	#$Sprite2D.play("atk02")
	
	var quiques = 3
	while quiques > 0:
		velocity.x = follow_dir * speed * 1.75  # Velocidade aumentada
		await get_tree().physics_frame
		
		if is_on_wall():
			quiques -= 1
			follow_dir = -follow_dir
			velocity.x = follow_dir * speed * 2
			await get_tree().create_timer(0.15).timeout  # Pausa no impacto
	
	velocity.x = 0
	#$Sprite2D.play("tonto")
	await get_tree().create_timer(1.25).timeout
	cur_state = state.cooldown


func _atk3():
	pass

func _atk4():
	pass
#endregion

func _cooldown():
	velocity.x = 0
	#$Sprite2D.play("idle")
	await get_tree().create_timer(atk_cooldown).timeout
	can_attack = true  # ← ADICIONADO: libera o próximo ataque
	cur_state = state.idle
#endregion

func _hurt():
	$Sprite2D.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color.WHITE
	
	# ← ADICIONADO: verifica morte primeiro
	if hp <= 0:
		cur_state = state.die
		return
	
	# ← ADICIONADO: verifica mudança de fase
	var hp_percent = float(hp) / float(hp_max)
	if hp_percent <= 0.5 and cur_fase == 1:
		cur_state = state.stage_change
	else:
		cur_state = state.idle

func _die():
	#$Sprite2D.play("die")
	velocity.x = 0
	set_physics_process(false)
	await get_tree().create_timer(1.0).timeout
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 1.0)  # Some em 1 segundo
	await tween.finished
	queue_free()

#region Fases
func _fase1():
	cur_fase = 1

func _fase2():
	cur_fase = 2
	speed = speed*1.25
	# novo padrão de ataque — adicionar ao pool de ataques
	atk_cooldown *= 0.75
#endregion
