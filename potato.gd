extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "villager" or body.name == "Villager":
		var episode = get_tree().current_scene

		if episode.has_method("collect_potato"):
			episode.collect_potato()

		queue_free()
