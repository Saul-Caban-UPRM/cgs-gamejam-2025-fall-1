extends Camera2D

@export var smoothing_enabled := true
@export var smoothing_speed := 8.0

var player: Node2D
var highest_y: float

func _ready():
	player = get_tree().root.find_child("FireFighter", true, false)
	# Start tracking from the camera's current position in the editor
	highest_y = global_position.y

func _process(delta):
	if not player:
		return

	# Only move up (smaller y in Godot coordinates = higher on screen)
	if player.global_position.y < highest_y:
		highest_y = player.global_position.y

	var target_y = highest_y
	if smoothing_enabled:
		global_position.y = lerp(global_position.y, target_y, clamp(delta * smoothing_speed, 0, 1))
	else:
		global_position.y = target_y
