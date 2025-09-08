extends CharacterBody2D
@export var speed = 300       # horizontal speed
@export var jump_velocity = -1000
@export var gravity = 1200
@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction = 0
	
	# Horizontal movement
	if Input.is_action_pressed("Walk_left"):
		direction -= 1
	if Input.is_action_pressed("Walk_right"):
		direction += 1
	#if Input.is_action_just_pressed("Walk_up"):
		#velocity.y = -1 * 1000 
	#Testing if the map kept going

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
