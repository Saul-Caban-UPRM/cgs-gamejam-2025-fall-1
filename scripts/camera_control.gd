extends Camera2D

@export var smoothing_enabled := true
@export var smoothing_speed := 8.0
@export var base_offset := 550.0   # how much higher than the player’s highest Y the camera goes

var player: Node2D
var highest_y := 0.0
var jump_started := false

var was_on_floor := true  # track if the player was on the floor last frame

func _ready():
	player = get_tree().root.find_child("FireFighter", true, false)
	if not player:
		return
	highest_y = 500  # starting camera Y

func _process(delta):
	if not player:
		return

	# Detect when the player actually leaves the floor
	if was_on_floor and not player.is_on_floor():
		jump_started = true
		highest_y = player.global_position.y

	was_on_floor = player.is_on_floor()

	# Determine target Y
	var target_y = highest_y
	if jump_started:
		target_y = highest_y - base_offset

	# Smooth follow
	if smoothing_enabled:
		global_position.y = lerp(global_position.y, target_y, clamp(delta * smoothing_speed, 0, 1))
	else:
		global_position.y = target_y
