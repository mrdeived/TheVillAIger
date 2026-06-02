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
                action = random.choice(ACTIONS)

                response = {
                    "type": "action",
                    "action": action
                }

                await websocket.send(json.dumps(response))
                print(f"State received. Sent action: {action}")

    except websockets.exceptions.ConnectionClosed:
        print("Godot disconnected.")


async def main():
    print(f"WebSocket server running on ws://{HOST}:{PORT}")

    async with websockets.serve(handle_client, HOST, PORT):
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())