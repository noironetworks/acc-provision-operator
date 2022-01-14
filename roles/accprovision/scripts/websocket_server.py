import asyncio
import pathlib
import ssl
import websockets
import os
from websockets import WebSocketClientProtocol
import json

BUFFER_SIZE = 1024
clients = set()

def find_input_file(system_id, search_path):
   result = ""
   for root, dir, files in os.walk(search_path):
      filename = system_id + "-input.yaml"
      if filename in files:
         result = os.path.join(root, filename)
   return result

def start_server():
    async def register(ws: WebSocketClientProtocol) -> None:
        clients.add(ws)
        print(f'{ws.remote_address} connects.')
        msg = await ws.recv()
        return msg

    async def unregister(ws: WebSocketClientProtocol) -> None:
        clients.remove(ws)
        print(f'{ws.remote_address} disconnects.')

    async def ws_handler(websocket, path):
        #msg = await websocket.recv()
        msg = await register(websocket)
        print(msg)
        filename = find_input_file(msg, "/path/to/dierctory/")
        f = open(filename, 'rb')
        l = f.read(BUFFER_SIZE)
        try:
            await websocket.send(l)
            print("Sent input file: ", filename, "to client")
        finally:
            await unregister(websocket)

    try:
        ssl_context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
        ssl_context.verify_mode = ssl.CERT_REQUIRED
        ssl_context.load_cert_chain(
            pathlib.Path(__file__).with_name('localhost.pem'), keyfile=pathlib.Path(__file__).with_name('localhost.key'))
        ssl_context.load_verify_locations("clientCerts.pem")
    except Exception as error:
        print(str(error))

    server = websockets.serve(
        ws_handler, 'localhost', 1231, ssl=ssl_context)

    asyncio.get_event_loop().run_until_complete(server)
    print("Server started")
    asyncio.get_event_loop().run_forever()

if __name__ == "__main__":
	start_server()