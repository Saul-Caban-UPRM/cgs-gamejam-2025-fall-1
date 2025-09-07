extends Area2D

@export var base_growth_speed: float = 50.0         # base speed used for visual growth
@export var growth_scaling_factor: float = 0.01     # base scalar for visual growth
@export var fire_rate_multiplier: float = 4.0       # multiply visual growth (increase this to make fire grow faster)

@export var collision_growth_multiplier: float = 2.3  # multiply how fast collision extents grow relative to sprite scale
@export var max_visual_scale_y: float = 20.0         # safety clamp for visual scale (avoid runaway)
@export var min_visual_scale_y: float = 1.0

@export var climb_reduction_factor: float = 0.01    # how much fire recedes when player climbs

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

	# Set up collision shape (duplicate so we can edit safely at runtime)
	collision_shape_node = $CollisionShape2D
	rect_shape = collision_shape_node.shape.duplicate() as RectangleShape2D
	collision_shape_node.shape = rect_shape
	original_extents = rect_shape.extents  # store half-size

	# Initialize player tracking
	if player:
		highest_player_y = player.global_position.y


func _process(delta):
	if not player or not camera:
		return

	# --- Visual growth (sprite) ---
	var sprite_scale = $AnimatedSprite2D.scale
	sprite_scale.y += base_growth_speed * delta * growth_scaling_factor * fire_rate_multiplier
	# clamp visual scale
	sprite_scale.y = clamp(sprite_scale.y, min_visual_scale_y, max_visual_scale_y)
	$AnimatedSprite2D.scale = sprite_scale

	# --- Reduce fire if player climbs ---
	if player.global_position.y < highest_player_y:
		var climb_diff = highest_player_y - player.global_position.y
		sprite_scale.y = max(min_visual_scale_y, sprite_scale.y - climb_diff * climb_reduction_factor)
		highest_player_y = player.global_position.y
		$AnimatedSprite2D.scale = sprite_scale

	# --- Collision extents grow separately (you can tune collision_growth_multiplier) ---
	# original_extents is half-size. We compute new extents based on sprite scale and the collision multiplier.
	var new_extents = Vector2(
		original_extents.x * sprite_scale.x,
		original_extents.y * sprite_scale.y * collision_growth_multiplier
	)
	# optional safety clamp to avoid zero or negative extents
	new_extents.x = max(0.1, new_extents.x)
	new_extents.y = max(0.1, new_extents.y)
	rect_shape.extents = new_extents

	# Keep collision shape visually anchored at bottom of the fire node:
	# move collision shape downward by the difference between new and original extents.
	collision_shape_node.position.y = (new_extents.y - original_extents.y)

	# --- Position fire at screen bottom (using extents correctly) ---
	var viewport_size = get_viewport().get_visible_rect().size
	var screen_bottom_y = camera.global_position.y + viewport_size.y * 0.80
	# position the Area2D so the bottom of the collision aligns with screen bottom
	position.y = screen_bottom_y - rect_shape.extents.y


func _on_body_entered(body):
	if body == player:
		player_fell()

func player_fell():
	for node in get_tree().get_nodes_in_group("Sounds"):
		if node != $Death:
			node.stop()
	$"../PlatformSpanwer/Death".play()
	await $"../PlatformSpanwer/Death".finished
	print("Player fell! Game Over.")
	GlobalScript.MenuStates = "Retry"
	GlobalScript.score = 0
	get_tree().change_scene_to_file("res://scenes/menu_manager.tscn")
