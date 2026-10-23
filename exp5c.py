import socket
import threading

def receive_messages(client_socket):
    while True:
        try:
            message = client_socket.recv(1024).decode()
            if not message:
                print("Disconnected from server.")
                break
            print(message)
        except Exception as e:
            print(f"Error receiving message: {e}")
            break

def chat_client():
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        client_socket.connect(('localhost', 55555))
        print("Connected to chat server.")
    except Exception as e:
        print(f"Unable to connect: {e}")
        return
    receive_thread = threading.Thread(
        target=receive_messages,
        args=(client_socket,),
        daemon=True
    )
    receive_thread.start()
    while True:
        try:
            message = input()
            if message.lower() == "exit":
                break
            client_socket.sendall(message.encode())
        except Exception as e:
            print(f"Error sending message: {e}")
            break
    client_socket.close()

if __name__ == '__main__':
    chat_client()
