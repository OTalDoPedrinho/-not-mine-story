extends Entity

#region Variáveis
#region Knockback
var knockback_dir: float = 0.0
@export var knockback_force: float = 100
#endregion

#region Coyote
var coyote_time: float = .15
var coyote_timer: float = 0.0
var was_on_floor: bool = false
#endregion

#region @
@export var j_force = 250
@export var j_force_min = 100
@export var dash_spd = 300
@export var dash_dur = .1
@export var iframes_time = .5
@export var projetil_cena: PackedScene = preload("res://cenas/projetil.tscn")

@onready var Animacao: AnimatedSprite2D = $AnimatedSprite2D
#endregion

#region Booleans
var iframed = false
var player_in_range = false
var is_jumping = false
#endregion

#region Variables
var pause_menu_instance = null
var game_over_instance = null
var shoot_timer = 0.0
var shoot_dur = .2
var iframes_timer = 0.0
var dash_cooldown = .4
var dash_timer = dash_cooldown
var dash_cur_dur = 0.0
var atk_timer = 0.0
var atk_dur = .5
#endregion

#region States
enum state {idle, walk, jump, dash, atk, shoot, take_dmg, die, talk}
var cur_state: state = state.idle
#endregion

#endregion

func _ready() -> void:
	if SaveLoad.SaveFileData.checkpoint_pos != Vector2.ZERO:
		global_position = SaveLoad.SaveFileData.checkpoint_pos
		hp = SaveLoad.SaveFileData.hp
		Global.has_dash = SaveLoad.SaveFileData.has_dash
		Global.has_picaxe = SaveLoad.SaveFileData.has_picaxe

func _physics_process(delta: float) -> void:
	if not is_node_ready():
		return
	
	var move_x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	
	dash_timer += delta

	#region Flip
	if velocity.x > 0:
		Animacao.flip_h = false
	elif velocity.x < 0:
		Animacao.flip_h = true
	#endregion

	#region Coyote
	if is_on_floor():
		coyote_timer = coyote_time
		was_on_floor = true
	else:
		coyote_timer -= delta
	var can_jump = is_on_floor() or coyote_timer > 0.0
	#endregion

	#region State Machine
	match cur_state:
		state.idle:
			_idle(move_x, can_jump)
		state.walk:
			_walk(move_x, can_jump)
		state.jump:
			_jump(move_x)
		state.dash:
			_dash(move_x, delta)
		state.atk:
			_atk(delta)
		state.shoot:
			_shoot(delta)
		state.take_dmg:
			_take_dmg(move_x, delta)
		state.die:
			_die()
		state.talk:
			_talk()
	#endregion

	#region Colisão
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		
		if not is_instance_valid(collider):
			continue
		
		if iframed:  # ← sai do loop inteiro se já tomou dano
			break
		
		if (collider.is_in_group("enemy") or collider is Enemy) and not iframed:
			hp -= collider.dmg
			knockback_dir = sign(global_position.x - collider.global_position.x)
			cur_state = state.take_dmg
			iframed = true
			break
		
		if collider.is_in_group("projetil") and not iframed:
			hp -= collider.dmg
			knockback_dir = sign(global_position.x - collider.global_position.x)
			cur_state = state.take_dmg
			iframed = true
			break
	#endregion
	
	velocity.y += Global.grvt
	move_and_slide()
	
	if Global.has_picaxe == false:
		dmg = 1
	else:
		dmg = 1.75

#region States
func _idle(move_x: int, can_jump: bool) -> void:
	Animacao.play("idle")
	velocity.x = 0

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

func _walk(move_x: int, can_jump: bool) -> void:
	Animacao.play("walk")
	velocity.x = move_x * speed

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
		shoot_timer = 0.0

func _jump(move_x: int) -> void:
	Animacao.play("jump")
	velocity.x = move_x * speed

	if Input.is_action_just_released("jump") and velocity.y < 0 and is_jumping:
		velocity.y = max(velocity.y, -j_force_min)
		is_jumping = false

	if velocity.y >= 0:
		is_jumping = false

	if is_on_floor():
		cur_state = state.idle
	if Input.is_action_just_pressed("shoot"):
		cur_state = state.shoot
		shoot_timer = 0.0
	if Input.is_action_just_pressed("dash") and Global.has_dash and dash_timer >= dash_cooldown:
		cur_state = state.dash
		dash_cur_dur = 0.0

func _dash(move_x: int, delta: float) -> void:
	dash_cur_dur += delta
	velocity.x = move_x * dash_spd if move_x != 0 else sign(scale.x) * dash_spd

	if dash_cur_dur >= dash_dur:
		dash_timer = 0.0
		cur_state = state.idle

func _atk(delta: float) -> void:
	atk_timer += delta
	velocity.x = 0
	$AtkHitbox.monitoring = true

	if atk_timer >= atk_dur:
		$AtkHitbox.monitoring = false
		cur_state = state.idle

func _take_dmg(move_x: int, delta: float) -> void:
	velocity.x = knockback_dir * knockback_force
	iframes_timer += delta
	
	if hp<=0:
		cur_state = state.die

	if iframes_timer >= iframes_time:
		iframes_timer = 0.0
		iframed = false
		knockback_dir = 0.0
		cur_state = state.idle
	
	if hp<=0:
		cur_state = state.die

func _die() -> void:
	# Instancia o Game Over
	var game_over = load("res://cenas/sistemas/game_over.tscn").instantiate()
	get_tree().root.add_child(game_over)
	game_over.mostrar_game_over()  # mostra e pausa

func _talk() -> void:
	velocity.x = 0
#endregion

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if pause_menu_instance == null or not is_instance_valid(pause_menu_instance):
			# Instancia o Pause Menu
			pause_menu_instance = load("res://cenas/sistemas/pause_menu.tscn").instantiate()
			get_tree().root.add_child(pause_menu_instance)
			pause_menu_instance.mostrar_pause()  # função que mostra o menu e pausa
		else:
			# Se já existe, fecha
			pause_menu_instance.fechar_pause()
			pause_menu_instance.queue_free()
			pause_menu_instance = null

func _on_atk_hitbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.tomar_dano(dmg, global_position)

func _shoot(delta: float) -> void:
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
