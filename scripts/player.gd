extends CharacterBody2D

@export var hp = 3
@export var speed = 100
@export var j_force = 250
@export var dash_spd = 1500
@export var dash_dur = 0.1
@export var atk_dur = 0.15

var has_picaxe = false
var has_dash = true
var dash_cooldown = 1
var dash_timer = dash_cooldown
var dash_cur_dur = 0.0
var atk_timer = 0.0

enum state {idle, walk, jump, dash, atk, shoot, squat, take_dmg, die}
var cur_state:state = state.idle

func _physics_process(delta: float) -> void:
	var move_x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	dash_timer += delta
	
	# State Machine
	match cur_state:
		state.idle:
			if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
				cur_state = state.walk
			if Input.is_action_just_pressed("jump") and is_on_floor():
				cur_state = state.jump
			if Input.is_action_just_pressed("dash") and has_dash and dash_timer >= dash_cooldown:
				cur_state = state.dash
				dash_cur_dur = 0.0
			if Input.is_action_just_pressed("atk"):
				cur_state = state.atk
				atk_timer = 0.0
		
		state.walk:
			velocity.x = move_x * speed
			if velocity.x == 0:
				cur_state = state.idle
			if Input.is_action_just_pressed("jump") and is_on_floor():
				cur_state = state.jump
			if Input.is_action_just_pressed("dash") and has_dash and dash_timer >= dash_cooldown:
				cur_state = state.dash
				dash_cur_dur = 0.0
			if Input.is_action_just_pressed("atk"):
				cur_state = state.atk
				atk_timer = 0.0
		
		state.jump:
			velocity.y = -j_force
			cur_state = state.idle
		
		state.dash:
			dash_cur_dur += delta
			velocity.x = move_x * dash_spd
			
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
	
	#region Colisão
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Enemy:
			if global_position.y < collider.global_position.y - 18:
				collider._pisado()
				velocity.y = -j_force * 0.6
			else:
				hp -= collider.dmg
	#endregion
	velocity.y += Global.grvt
	
	move_and_slide()

func _on_atk_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.tomar_dano()
