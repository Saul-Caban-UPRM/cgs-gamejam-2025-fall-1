extends Area2D

@export var score_value: int = 5

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GlobalScript.score += score_value
		queue_free() 
