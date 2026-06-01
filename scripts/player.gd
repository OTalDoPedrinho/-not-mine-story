extends CharacterBody2D

#region Variáveis
#region @
@export var hp = 3
@export var speed = 100
@export var j_force = 250
@export var dash_spd = 300
@export var dash_dur = 0.1
@export var iframes_time = .75
@export var projetil_cena: PackedScene = preload("res://cenas/projetil.tscn")
#endregion

#region Booleans
var iframed = false
var squat = false
#endregion

#region Variables
var knockback_dir

var shoot_timer = 0.0
var shoot_dur = 0.2
var iframes_timer = 0
var dash_cooldown = .4
var dash_timer = dash_cooldown
var dash_cur_dur = 0.0
var atk_timer = 0.0
var atk_dur = 0.15
#endregion

#region States
enum state {idle, walk, jump, dash, atk, shoot, squat, take_dmg, die, talk}
var cur_state:state = state.idle
#endregion

#endregion

func _physics_process(delta: float) -> void:
	print(str(hp))
	
	var move_x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	dash_timer += delta
	
	# State Machine
	match cur_state:
		state.idle:
			if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
				cur_state = state.walk
			if Input.is_action_just_pressed("jump") and is_on_floor():
				cur_state = state.jump
			if Input.is_action_just_pressed("dash") and Global.has_dash and dash_timer >= dash_cooldown:
				cur_state = state.dash
				dash_cur_dur = 0.0
			if Input.is_action_just_pressed("atk"):
				cur_state = state.atk
				atk_timer = 0.0
			if Input.is_action_just_pressed("shoot"):
				cur_state = state.shoot
				shoot_timer = 0.0
		state.walk:
			velocity.x = move_x * speed
			
			if velocity.x == 0:
				cur_state = state.idle
			if Input.is_action_just_pressed("jump") and is_on_floor():
				cur_state = state.jump
			if Input.is_action_just_pressed("dash") and Global.has_dash and dash_timer >= dash_cooldown:
				cur_state = state.dash
				dash_cur_dur = 0.0
			if Input.is_action_just_pressed("atk"):
				cur_state = state.atk
				atk_timer = 0.0
			if Input.is_action_just_pressed("shoot"):
				cur_state = state.shoot
				shoot_timer = 0
		state.jump:
			velocity.y = -j_force
			cur_state = state.idle
			
			if Input.is_action_just_pressed("shoot"):
				cur_state = state.shoot
				shoot_timer = 0
		state.dash:
			dash_cur_dur += delta
			velocity.x = move_x * dash_spd if move_x != 0 else sign(scale.x) * dash_spd
			
			if dash_cur_dur >= dash_dur:
				dash_timer = 0
				cur_state = state.idle
		state.atk:
			atk_timer += delta
			velocity.x = 0
			$AtkHitbox.monitoring = true
			
			if atk_timer >= atk_dur:
				$AtkHitbox.monitoring = false
				cur_state = state.idle
		state.shoot:
			_shoot(delta)
		state.squat:
			squat = true
		state.take_dmg:
			pass
			iframes_timer+=delta
			velocity.x = knockback_dir*25 #knockback
			velocity.y = -15 #knockback
			
			if iframes_timer>=iframes_time:
				iframes_timer = 0
				iframed = false
				velocity.x = move_x*speed
				cur_state = state.idle
		state.die:
			velocity.x = 0
			queue_free()
		state.talk:
			velocity.x = 0
			_dialogue()
	
	#region Colisão
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		
		if not is_instance_valid(collider):
			continue
		
		if collider is Enemy and not iframed and collider.p_collidiu:
			hp -= collider.dmg
			cur_state = state.take_dmg
			knockback_dir = sign(global_position.x - collider.global_position.x)
			collider.p_collidiu = false
		if collider.is_in_group('projetil'):
			continue
	#endregion
	velocity.y += Global.grvt
	
	move_and_slide()

func _on_atk_hitbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.tomar_dano()

func _dialogue():
	pass

func _shoot(delta: float):
	if shoot_timer == 0.0:
		var mouse_pos = get_global_mouse_position()
		var shoot_dir = (mouse_pos - global_position).normalized()
		var projetil = projetil_cena.instantiate()
		projetil.global_position = global_position + shoot_dir * 20
		projetil.velocity = shoot_dir * projetil.speed
		get_parent().add_child(projetil)
	
	shoot_timer += delta
	if shoot_timer >= shoot_dur:
		cur_state = state.idle
