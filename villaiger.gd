extends CharacterBody2D

@export var speed: float = 45.0
@export var server_url: String = "ws://127.0.0.1:8765"
@export var command_timeout: float = 0.5

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var websocket := WebSocketPeer.new()
var current_action: String = "idle"
var time_since_last_command: float = 0.0

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


func read_websocket_messages() -> void:
	while websocket.get_available_packet_count() > 0:
		var packet := websocket.get_packet()
		var message := packet.get_string_from_utf8()

		var json := JSON.new()
		var result := json.parse(message)

		if result != OK:
			print("Invalid JSON received: ", message)
			return

		var data = json.data

		if data.has("action"):
			var received_action: String = str(data["action"]).to_lower()

			if action_vectors.has(received_action):
				current_action = received_action
				time_since_last_command = 0.0
				print("Received action: ", current_action)
			else:
				print("Unknown action: ", received_action)
