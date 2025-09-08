extends CharacterBody2D
@export var speed = 300       # horizontal speed
@export var jump_velocity = -1200
@export var gravity = 1500

@export var wrap_margin := 0   # optional padding before wrapping
@onready var anim = $AnimatedSprite2D
func _physics_process(delta: float) -> void:
	var direction = 0
	
	# Horizontal movement
	if Input.is_action_pressed("Walk_left"):
		direction -= 1
	if Input.is_action_pressed("Walk_right"):
		direction += 1

	velocity.x = direction * speed

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if is_on_floor() and Input.is_action_just_pressed("Jump"):
		$Jump.play()
		velocity.y = jump_velocity


	if direction != 0:
		anim.play("walking_right")
		anim.flip_h = direction < 0
		
	else:
		anim.stop()                  
		anim.frame = 0	

	# Move the character
	move_and_slide()

	# --- Screen wrapping ---
	var screen_width = get_viewport().get_visible_rect().size.x
	
	if global_position.x < -wrap_margin:
		global_position.x = screen_width + wrap_margin
	elif global_position.x > screen_width + wrap_margin:
		global_position.x = -wrap_margin
