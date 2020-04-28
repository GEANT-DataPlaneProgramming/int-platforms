import socket
import sys

# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Bind the socket to the port
server_address = ('10.0.0.254', 682)
print('starting up on %s port %s' % server_address)
sock.bind(server_address)

while True:
    print('\nwaiting to receive message')
    data, address = sock.recvfrom(4096)
    
    print('received %s bytes from %s' % (len(data), address))
    print(data)
    
    if data:
        sent = sock.sendto(data, address)