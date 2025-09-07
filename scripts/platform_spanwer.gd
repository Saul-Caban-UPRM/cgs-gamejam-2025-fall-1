extends Node2D

@export var platform_scene: PackedScene
@export var player_path: NodePath
@export var camera_node: Camera2D
@export var min_x: float = 0.0
@export var max_x: float = 620.0
@export var y_spacing: float = 400.0

var player: CharacterBody2D
var next_spawn_y: float
var platforms: Array = []

func _ready():
	player = get_node(player_path)
	next_spawn_y = player.global_position.y

func _process(delta):
	# Spawn platforms above the player continuously
	while next_spawn_y > player.global_position.y - 1280:  # 1280 = screen height
		spawn_platform(next_spawn_y)
		next_spawn_y -= y_spacing

	# Remove platforms below camera
	cleanup_platforms()

	# Check if player fell below camera
	check_player_fall()

func spawn_platform(y_pos: float):
	var platform = platform_scene.instantiate()
	var x_pos = randf_range(min_x, max_x)
	platform.global_position = Vector2(x_pos, y_pos)
	add_child(platform)
	platforms.append(platform)

func cleanup_platforms():
	if not camera_node:
		return
	var screen_bottom_y = camera_node.global_position.y + get_viewport().get_visible_rect().size.y / 2
	for p in platforms.duplicate():
		if p.global_position.y > screen_bottom_y + 100:
			platforms.erase(p)
			p.queue_free()

func check_player_fall():
	if not camera_node:
		return
	var screen_bottom_y = camera_node.global_position.y + get_viewport().get_visible_rect().size.y / 2
	if player.global_position.y > screen_bottom_y:
		player_fell()

func player_fell():
	GlobalScript.score = 0
	print("Player fell! Game Over.")
	GlobalScript.MenuStates = "Retry"
	get_tree().change_scene_to_file("res://scenes/menu_manager.tscn")
	
	
# Make platform eventually smaller, after reaching the minimum make them move from left to right 
