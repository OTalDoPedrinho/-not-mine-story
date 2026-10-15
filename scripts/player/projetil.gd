extends Entity

var velocity_vector = Vector2.RIGHT
var shooter

func _ready():
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	velocity.y += Global.grvt
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		var collider = get_slide_collision(0).get_collider()
		if collider.has_method("tomar_dano"):
			collider.tomar_dano()
