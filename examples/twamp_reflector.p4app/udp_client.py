import socket
import sys

# Create a UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

server_address = ('10.0.0.254', 862)
message = b'This is the message.  It will be repeated.'

try:
    # Send data
    sent = sock.sendto(message, server_address)

    # Receive response
    data, server = sock.recvfrom(4096)
    print('received "%s"' % data)
finally:
    sock.close()