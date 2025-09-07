extends Camera2D

@export var smoothing_enabled := true
@export var smoothing_speed := 8.0
@export var base_offset := 550.0   # how much higher than the player’s highest Y the camera goes

var player: Node2D
var highest_y:=  0.0
var jump_started := false   # track if the player has jumped at least once

func _ready():
	player = get_tree().root.find_child("FireFighter", true, false)
	if not player:
		return
	highest_y = global_position.y  # keep the starting camera position

func _process(delta):
	if not player:
		return

	# Only start tracking after first jump
	if Input.is_action_just_pressed("Jump"):
		if player.global_position.y < highest_y:
			jump_started = true
			highest_y = player.global_position.y

	# If no jump yet, keep the starting position
	var target_y = highest_y
	if jump_started:
		target_y = highest_y - base_offset

	# Smooth follow
	if smoothing_enabled:
		global_position.y = lerp(global_position.y, target_y, clamp(delta * smoothing_speed, 0, 1))
	else:
		global_position.y = target_y
