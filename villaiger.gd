extends CharacterBody2D

@export var speed: float = 45.0
@export var server_url: String = "ws://127.0.0.1:8765"
@export var action_interval: float = 0.25
@export var command_timeout: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var websocket := WebSocketPeer.new()

var current_action: String = "idle"
var time_since_last_command: float = 0.0

var action_timer: float = 0.0
var waiting_for_action: bool = false

var action_vectors := {
	"idle": Vector2.ZERO,
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT
}


func _ready() -> void:
	var error := websocket.connect_to_url(server_url)

	if error != OK:
		push_error("Could not connect to WebSocket server.")
	else:
		print("Trying to connect to Python WebSocket server...")

	animated_sprite.play("idle")


func _process(delta: float) -> void:
	websocket.poll()

	var state := websocket.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		read_websocket_messages()
	elif state == WebSocketPeer.STATE_CLOSED:
		pass


func _physics_process(delta: float) -> void:
	if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		action_timer += delta

		if action_timer >= action_interval and not waiting_for_action:
			action_timer = 0.0
			send_state_to_python()

	time_since_last_command += delta

	if time_since_last_command > command_timeout:
		current_action = "idle"

	var direction: Vector2 = action_vectors[current_action]

	velocity = direction * speed

	if direction == Vector2.ZERO:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
	else:
		if animated_sprite.animation != "walking":
			animated_sprite.play("walking")

		if direction.x < 0:
			animated_sprite.flip_h = true
		elif direction.x > 0:
			animated_sprite.flip_h = false

	move_and_slide()


func send_state_to_python() -> void:
	var episode = get_tree().current_scene

	var state_data := {}

	if episode.has_method("get_environment_state"):
		state_data = episode.get_environment_state()
	else:
		state_data = {
			"type": "state",
			"villaiger_x": global_position.x,
			"villaiger_y": global_position.y
		}

	state_data["current_action"] = current_action

	var message := JSON.stringify(state_data)
	websocket.send_text(message)

	waiting_for_action = true


func read_websocket_messages() -> void:
	while websocket.get_available_packet_count() > 0:
		var packet := websocket.get_packet()
		var message := packet.get_string_from_utf8()

		var json := JSON.new()
		var result := json.parse(message)

		if result != OK:
			print("Invalid JSON received: ", message)
			waiting_for_action = false
			return

		var data = json.data

		if data.has("type") and data["type"] == "action":
			var received_action: String = str(data["action"]).to_lower()

			if action_vectors.has(received_action):
				current_action = received_action
				time_since_last_command = 0.0
				waiting_for_action = false
				print("Received action: ", current_action)
			else:
				print("Unknown action: ", received_action)
				waiting_for_action = false
