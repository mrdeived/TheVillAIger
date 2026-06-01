extends Node2D

@export var time_limit: float = 60.0
@export var goal_potatoes: int = 5
@export var inventory_capacity: int = 5
@export var potato_scene: PackedScene

@onready var floor_tilemap: TileMapLayer = $floor
@onready var potatoes_container: Node2D = $Potatoes

@onready var episode_label: Label = $WorldLabels/EpisodeLabel
@onready var potatoes_label: Label = $WorldLabels/PotatoesLabel
@onready var timer_label: Label = $WorldLabels/TimerLabel
@onready var score_label: Label = $WorldLabels/ScoreLabel

var time_left: float
var inventory_count: int = 0
var score: int = 0
var episode_finished: bool = false


func _ready() -> void:
	time_left = time_limit
	inventory_count = 0
	score = 0
	episode_finished = false

	print("Episode 1 started.")
	print("Goal: collect ", goal_potatoes, " potatoes in ", time_limit, " seconds.")

	spawn_potatoes()
	update_labels()


func _process(delta: float) -> void:
	if episode_finished:
		return

	time_left -= delta

	if time_left <= 0:
		time_left = 0
		update_labels()
		lose_episode()
		return

	update_labels()


func spawn_potatoes() -> void:
	if potato_scene == null:
		push_error("Potato scene is not assigned in Episode1.")
		return

	if potatoes_container == null:
		push_error("Potatoes container not found. Create a Node2D named 'Potatoes' under Episode1.")
		return

	clear_old_potatoes()

	var floor_cells: Array[Vector2i] = floor_tilemap.get_used_cells()

	if floor_cells.is_empty():
		push_error("No floor cells found in floor TileMapLayer.")
		return

	var spawned_count := 0
	var attempts := 0
	var max_attempts := 300

	while spawned_count < goal_potatoes and attempts < max_attempts:
		attempts += 1

		var random_cell: Vector2i = floor_cells.pick_random()

		var potato = potato_scene.instantiate()
		potato.name = "potato"

		potatoes_container.add_child(potato)

		var local_position: Vector2 = floor_tilemap.map_to_local(random_cell)
		var world_position: Vector2 = floor_tilemap.to_global(local_position)

		potato.global_position = world_position

		spawned_count += 1

	print("Spawned potatoes: ", spawned_count)


func clear_old_potatoes() -> void:
	if potatoes_container == null:
		push_error("Potatoes container not found. Create a Node2D named 'Potatoes' under Episode1.")
		return

	for child in potatoes_container.get_children():
		child.queue_free()


func collect_potato() -> void:
	if episode_finished:
		return

	if inventory_count >= inventory_capacity:
		print("Inventory full.")
		return

	inventory_count += 1
	score += 10

	print("Potato collected: \n", inventory_count, "/", goal_potatoes)
	print("Score: \n", score)
	print("Time left: \n", snapped(time_left, 0.01))

	update_labels()

	if inventory_count >= goal_potatoes:
		win_episode()


func win_episode() -> void:
	episode_finished = true
	score += 50
	update_labels()

	print("Episode completed. The VillAIger collected all potatoes.")
	print("Final score: ", score)


func lose_episode() -> void:
	episode_finished = true
	update_labels()

	print("Episode failed. Time ran out.")
	print("Final inventory: ", inventory_count, "/", goal_potatoes)
	print("Final score: ", score)


func update_labels() -> void:
	episode_label.text = "Episode 1"
	potatoes_label.text = "Potatoes: \n" + str(inventory_count) + "/" + str(goal_potatoes)
	timer_label.text = "Time: \n" + str(snapped(time_left, 0.1))
	score_label.text = "Score: \n" + str(score)
