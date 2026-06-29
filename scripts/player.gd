extends Entity

#ESTOU DESESPERADO

#region Variáveis
#region Coyote
var coyote_time: float = 0.15
var coyote_timer: float = 0.0
var was_on_floor: bool = false
#endregion

#region @
@export var j_force = 250
@export var j_force_min = 100
@export var dash_spd = 300
@export var dash_dur = 0.1
@export var iframes_time = 1.5
@export var projetil_cena: PackedScene = preload("res://cenas/projetil.tscn")
#endregion

#region Booleans
var iframed = false
var player_in_range = false
#endregion

#region Variables
var is_jumping = false
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
enum state {idle, walk, jump, dash, atk, shoot, take_dmg, die, talk}
var cur_state: state = state.idle
#endregion

#endregion

func _physics_process(delta: float) -> void:
	print(str(hp))
	
	var move_x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	
	dash_timer += delta
	
	#region Coyote
	if velocity.x > 0:
		$Sprite2D.flip_h = false
	elif velocity.x < 0:
		$Sprite2D.flip_h = true
	
	if is_on_floor():
		coyote_timer = coyote_time
		was_on_floor = true
	else:
		coyote_timer -= delta
	var can_jump = is_on_floor() or coyote_timer > 0.0
	#endregion
	
	match cur_state:
		state.idle:
			$Sprite2D.play("Idle")
			
			if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
				cur_state = state.walk
			if Input.is_action_just_pressed("jump") and can_jump:
				cur_state = state.jump
				velocity.y = -j_force
				coyote_timer = 0.0
				is_jumping = true
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
			
			$Sprite2D.play("Walk")
			
			if move_x == 0:
				cur_state = state.idle
			
			if Input.is_action_just_pressed("jump") and can_jump:
				cur_state = state.jump
				velocity.y = -j_force
				coyote_timer = 0.0
				is_jumping = true
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
			$Sprite2D.play("Jump")
			velocity.x = move_x * speed
			
			# soltou o botão antes de atingir o pico → corta o pulo
			if Input.is_action_just_released("jump") and velocity.y < 0 and is_jumping:
				velocity.y = max(velocity.y, -j_force_min)
				is_jumping = false
				
			# chegou no pico ou no chão → pulo acabou
			if velocity.y >= 0:
				is_jumping = false
			
			if is_on_floor():
				cur_state = state.idle
			
			if Input.is_action_just_pressed("shoot"):
				cur_state = state.shoot
				shoot_timer = 0
			if Input.is_action_just_pressed("dash") and Global.has_dash and dash_timer >= dash_cooldown:
				cur_state = state.dash
				dash_cur_dur = 0.0
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
		state.take_dmg:
			iframes_timer+=delta
			
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
	
	#region Colisão
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		
		if not is_instance_valid(collider):
			continue
		
		if collider is Enemy and not iframed and collider.p_colidiu:
			hp -= collider.dmg
			cur_state = state.take_dmg
			collider.p_colidiu = false
			iframed = true
			
			print("colidiu com: ", collider.name, " | grupo enemy: ", collider.is_in_group("enemy"), " | iframed: ", iframed, " | p_colidiu: ", collider.get("p_colidiu"))
			
		if collider.is_in_group('projetil') and not iframed:
			hp -= collider.dmg
			cur_state = state.take_dmg
			iframed = true
			print("dano tomado! hp: ", hp)
	#endregion
	
	velocity.y += Global.grvt
	
	move_and_slide()
	
	if Input.is_action_just_pressed("save"):
		SaveLoad.SaveFileData.hp = hp
		SaveLoad.SaveFileData.checkpoint_pos = global_position
		'SaveLoad.SaveFileData.cur_area = cur_area
		SaveLoad.SaveFileData.cur_room = cur_room'
		SaveLoad.SaveFileData.has_dash = Global.has_dash
		SaveLoad.SaveFileData.has_picaxe = Global.has_picaxe
		'SaveLoad.SaveFileData.mentiu_batmom = Global.mentiu_batmom
		SaveLoad.SaveFileData.toadiana_ajudou = Global.toadiana_ajudou
		SaveLoad.SaveFileData.bosses_derrotados = Global.bosses_derrotados
		SaveLoad.SaveFileData.npcs_encontrados = Global.npcs_encontrados'
		SaveLoad._save()
	if Input.is_action_just_pressed("load"):
		SaveLoad._load()
		hp = SaveLoad.SaveFileData.hp
		'cur_area = SaveLoad.SaveFileData.cur_area
		cur_room = SaveLoad.SaveFileData.cur_room'
		global_position = SaveLoad.SaveFileData.checkpoint_pos
		Global.has_dash = SaveLoad.SaveFileData.has_dash
		Global.has_picaxe = SaveLoad.SaveFileData.has_picaxe
		'Global.mentiu_batmom = SaveLoad.SaveFileData.mentiu_batmom
		Global.toadiana_ajudou = SaveLoad.SaveFileData.toadiana_ajudou
		Global.bosses_derrotados = SaveLoad.SaveFileData.bosses_derrotados
		Global.npcs_encontrados = SaveLoad.SaveFileData.npcs_encontrados'
	
	if Global.has_picaxe == false:
		dmg = 1
	else:
		dmg = 1.75

func _on_atk_hitbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.tomar_dano(dmg, global_position)

func _shoot(delta: float):
	if shoot_timer <= 0.0:
		var mouse_pos = get_global_mouse_position()
		var shoot_dir = (mouse_pos - global_position).normalized()
		var projetil = projetil_cena.instantiate()
		projetil.global_position = global_position + shoot_dir * 20
		projetil.velocity = shoot_dir * projetil.speed
		get_parent().add_child(projetil)
	
	shoot_timer += delta
	if shoot_timer >= shoot_dur:
		cur_state = state.idle
