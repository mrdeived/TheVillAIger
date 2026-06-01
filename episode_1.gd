extends Node2D

@export var time_limit: float = 60.0
@export var goal_potatoes: int = 5
@export var inventory_capacity: int = 5
@export var potato_scene: PackedScene

@onready var floor_tilemap: TileMapLayer = $floor
@onready var potatoes_container: Node2D = $Potatoes

var time_left: float
var inventory_count: int = 0
var episode_finished: bool = false


func _ready() -> void:
	time_left = time_limit

	print("Episode 1 started.")
	print("Goal: collect ", goal_potatoes, " potatoes in ", time_limit, " seconds.")

	spawn_potatoes()


func _process(delta: float) -> void:
	if episode_finished:
		return

	time_left -= delta

	if time_left <= 0:
		time_left = 0
		lose_episode()


func spawn_potatoes() -> void:
	if potato_scene == null:
		push_error("Potato scene is not assigned in Episode1.")
		return

	clear_old_potatoes()

	var used_rect: Rect2i = floor_tilemap.get_used_rect()
	var spawned_count := 0
	var max_attempts := 200
	var attempts := 0

	while spawned_count < goal_potatoes and attempts < max_attempts:
		attempts += 1

		var random_cell := Vector2i(
			randi_range(used_rect.position.x, used_rect.position.x + used_rect.size.x - 1),
			randi_range(used_rect.position.y, used_rect.position.y + used_rect.size.y - 1)
		)

		var tile_data := floor_tilemap.get_cell_tile_data(random_cell)

		if tile_data == null:
			continue

		var potato = potato_scene.instantiate()
		potato.name = "potato"

		var local_position := floor_tilemap.map_to_local(random_cell)
		var world_position := floor_tilemap.to_global(local_position)

		potato.global_position = world_position
		potatoes_container.add_child(potato)

		spawned_count += 1

	print("Spawned potatoes: ", spawned_count)


func clear_old_potatoes() -> void:
	for child in potatoes_container.get_children():
		child.queue_free()


func collect_potato() -> void:
	if episode_finished:
		return

	if inventory_count >= inventory_capacity:
		print("Inventory full.")
		return

	inventory_count += 1

	print("Potato collected: ", inventory_count, "/", goal_potatoes)
	print("Time left: ", snapped(time_left, 0.01))

	if inventory_count >= goal_potatoes:
		win_episode()


func win_episode() -> void:
	episode_finished = true
	print("Episode completed. The VillAIger collected all potatoes.")


func lose_episode() -> void:
	episode_finished = true
	print("Episode failed. Time ran out.")
	print("Final inventory: ", inventory_count, "/", goal_potatoes)
