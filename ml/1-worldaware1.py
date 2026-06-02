import asyncio
import json
import random
import websockets

HOST = "127.0.0.1"
PORT = 8765

ACTIONS = ["up", "down", "left", "right", "idle"]


async def handle_client(websocket):
    print("Godot connected.")

    try:
        async for message in websocket:
            data = json.loads(message)

            if data.get("type") == "state":
                print("\nState received")
                print("Villaiger:", data.get("villaiger_x"), data.get("villaiger_y"))
                print("Potatoes:", data.get("potatoes"))
                print("Inventory:", data.get("inventory_count"), "/", data.get("goal_potatoes"))
                print("Time left:", data.get("time_left"))
                print("Score:", data.get("score"))
                print("Episode finished:", data.get("episode_finished"))

                action = random.choice(ACTIONS)

                response = {
                    "type": "action",
                    "action": action
                }

                await websocket.send(json.dumps(response))
                print("Sent action:", action)

    except websockets.exceptions.ConnectionClosed:
        print("Godot disconnected.")


async def main():
    print(f"WebSocket server running on ws://{HOST}:{PORT}")

    async with websockets.serve(handle_client, HOST, PORT):
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())