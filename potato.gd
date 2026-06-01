extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	print("Something touched potato: ", body.name)

	if body.name == "villaiger" or body.name == "Villaiger":
		var episode = get_tree().current_scene

		if episode.has_method("collect_potato"):
			episode.collect_potato()

		queue_free()
