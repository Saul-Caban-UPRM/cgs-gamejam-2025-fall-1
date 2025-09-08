extends Area2D

@export var score_value: int = 5

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GlobalScript.score += score_value
		# Tell fire to shrink
		var fire = get_tree().root.find_child("Fire", true, false)  # adjust if your fire node has a different name
		if fire:
			fire.reduce_fire(5.0)  # shrink by 2 units, tweak as needed

		queue_free() 
