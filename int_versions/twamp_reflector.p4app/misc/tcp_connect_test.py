import socket
import sys
import time

HOST, PORT = "10.0.0.254", 862

# SOCK_DGRAM is the socket type to use for UDP sockets
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# As you can see, there is no connect() call; UDP has no connections.
# Instead, data is directly sent to the recipient via sendto().
try:
    # Connect to server and send data
    sock.connect((HOST, PORT))
    print("Message1:", sock.recv(1024))
    sock.sendall(b"Data1")
    time.sleep(0.5)
    # Receive data from the server and shut down
    print("Message2:", sock.recv(1024))
    time.sleep(0.5)
    
    sock.sendall(b"Data2")
    time.sleep(0.5)
    # Receive data from the server and shut down
    print("Message3:",  sock.recv(1024))
    time.sleep(0.5)
finally:
    sock.close()






