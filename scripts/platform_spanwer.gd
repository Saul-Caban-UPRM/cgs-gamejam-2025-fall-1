extends Node2D

@export var platform_scene: PackedScene
@export var fire_hydrant_scene: PackedScene
@export var player_path: NodePath
@export var camera_node: Camera2D
@export var min_x: float = 0.0
@export var max_x: float = 620.0
@export var y_spacing: float = 400.0
@export var hydrant_chance: float = 0.3  # 30% chance per platform
@export var starter_platform_path: NodePath

var player: CharacterBody2D
var next_spawn_y: float
var platforms: Array = []
var hydrants: Array = []
var platform_count: int = 0

func _ready():
	if player_path != NodePath(""):
		player = get_node_or_null(player_path)
	else:
		player = get_tree().root.find_child("FireFighter", true, false)

	# Get starter platform Y
	var starter_platform_y = 0.0
	if starter_platform_path != NodePath(""):
		var starter_platform = get_node_or_null(starter_platform_path)
		if starter_platform:
			starter_platform_y = starter_platform.global_position.y
		else:
			push_error("Starter platform not found!")
	
	# Initialize next_spawn_y **y_spacing above starter platform**
	next_spawn_y = starter_platform_y - y_spacing

	if not player:
		push_error("Player not found! Did you set 'player_path' in the Inspector?")

func _process(delta):
	if not player:
		return

	# Spawn platforms (and maybe hydrants) above the player
	while next_spawn_y > player.global_position.y - 1280:
		spawn_platform_and_hydrant(next_spawn_y)
		next_spawn_y -= y_spacing

	cleanup_platforms_and_hydrants()

func spawn_platform_and_hydrant(y_pos: float):
	platform_count += 1

	var x_pos = randf_range(min_x, max_x)

	# Platform
	var platform = platform_scene.instantiate()
	platform.global_position = Vector2(x_pos, y_pos)
	add_child(platform)
	platforms.append(platform)

	# Spawn hydrant every 2 platforms
	if platform_count % 2 == 0:
		var hydrant = fire_hydrant_scene.instantiate()
		var opposite_x = max_x - (x_pos - min_x)
		hydrant.global_position = Vector2(opposite_x, y_pos - 80)
		add_child(hydrant)
		hydrants.append(hydrant)


func cleanup_platforms_and_hydrants():
	if not camera_node:
		return

	var bottom_y = camera_node.global_position.y + get_viewport().get_visible_rect().size.y / 2

	for p in platforms.duplicate():
		if p.global_position.y > bottom_y + 100:
			platforms.erase(p)
			p.queue_free()
