extends Node2D

@export var score_label: Label

func _ready() -> void:
	# Start the async loop
	increment_score_async()

# This is an async function
func increment_score_async() -> void:
	while true:
		GlobalScript.score += 1
		await get_tree().create_timer(1.0).timeout  # wait 1 second safely
		if GlobalScript.Maxscore < GlobalScript.score:
			GlobalScript.Maxscore = GlobalScript.score
func _process(delta: float) -> void:
	score_label.text = "Score: " + str(GlobalScript.Maxscore) 
# 
#
#
#
#
