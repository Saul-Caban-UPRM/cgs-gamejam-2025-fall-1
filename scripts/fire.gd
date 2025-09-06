extends Area2D

@export var base_growth_speed: float = 50.0  # Fire growth speed
@export var growth_scaling_factor: float = 0.01  # Controls how much the fire grows per unit
@export var climb_reduction_factor: float = 0.01  # Controls how much fire recedes when player climbs

var player: CharacterBody2D
var highest_player_y: float
var camera: Camera2D

var original_extents: Vector2
var collision_shape_node: CollisionShape2D
var rect_shape: RectangleShape2D

func _ready():
	# Get references to nodes
	player = get_parent().get_node_or_null("FireFighter")
	camera = get_parent().get_node_or_null("MainCamera")
	
	# Play fire animation
	$AnimatedSprite2D.play()

	# Set up collision shape
	collision_shape_node = $CollisionShape2D
	
	# Duplicate the shape once so we can safely modify it at runtime
	rect_shape = collision_shape_node.shape.duplicate() as RectangleShape2D
	collision_shape_node.shape = rect_shape
	original_extents = rect_shape.extents

	# Initialize player tracking
	if player:
		highest_player_y = player.global_position.y

func _process(delta):
	if not player or not camera:
		return

	# Get current sprite scale
	var sprite_scale = $AnimatedSprite2D.scale

	# --- Grow fire continuously ---
	sprite_scale.y += base_growth_speed * delta * growth_scaling_factor
	$AnimatedSprite2D.scale = sprite_scale

	# --- Lower fire if player climbs higher ---
	if player.global_position.y < highest_player_y:
		var climb_diff = highest_player_y - player.global_position.y
		sprite_scale.y = max(1.0, sprite_scale.y - climb_diff * climb_reduction_factor)
		highest_player_y = player.global_position.y
		$AnimatedSprite2D.scale = sprite_scale

	# --- Update collision shape to match sprite scale ---
	# Method 1: Using extents (half-size)
	#rect_shape.extents = Vector2(
		#original_extents.x * sprite_scale.x,
		#original_extents.y * sprite_scale.y
	#)
	
	# Alternative Method 2: Using full size (uncomment if Method 1 has issues)
	rect_shape.size = Vector2(
	 	original_extents.x * 2 * sprite_scale.x,
	 	original_extents.y * 2 * sprite_scale.y
	 )
	
	# Keep collision shape centered
	collision_shape_node.position = Vector2.ZERO

	# --- Position fire at screen bottom ---
	var viewport_size = get_viewport().get_visible_rect().size
	var screen_bottom_y = camera.global_position.y + viewport_size.y * 0.75
	position.y = screen_bottom_y - rect_shape.extents.y

func _on_body_entered(body):
	if body == player:
		player_fell()

func player_fell():
	print("Player fell! Game Over.")
	get_tree().change_scene_to_file("res://scenes/menu_manager.tscn")
