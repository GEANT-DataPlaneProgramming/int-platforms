import socketserver
import socket
import time
import logging
import threading
from enum import IntEnum
import os
from construct import Struct, Int64ub, Int32ub, Int16ub, Int8ub, Float32b, Bytes 

TWAMP_CONTROL_IP = "10.0.0.254"
TWAMP_CONTROL_PORT = 862
TWAMP_TEST_PORT = 8975

log = logging.getLogger(__name__)

### TWAMP MESSAGES ###

class Command(IntEnum):
	Reserved = 0
	Forbidden = 1
	StartSessions = 2
	StopSessions = 3
	Reserved2 = 4
	RequestSession = 5
	Experimentation = 6
	
class Authentication(IntEnum):
	Unauthenticated = 1
	Authenticated = 2
	Encrypted = 3

class Accept(IntEnum):
	AcceptOK = 0
	AcceptFailure = 1
	AcceptInternalError = 2
	AcceptNotSupported = 3
	AcceptPermLimit = 4
	AcceptTempLimit = 5

Timestamp =  Struct(
	"seconds" / Int32ub,
	"fraction" / Float32b
)

ServerGreeting = Struct (
	"unused" / Bytes(12),
	"modes" / Int32ub,
	"challenge" / Bytes(16),
	"salt" / Bytes(16),
	"count" / Int32ub,
	"mbz" /  Bytes(12)
)

SetupResponse = Struct (
	"mode" / Int32ub,
	"keyID" / Bytes(80),
	"token" / Bytes(64),
	"clientIV" / Bytes(16)
)

SetupResponseSimple = Struct (
	"mode" / Int32ub,
	"keyID" / Bytes(80)
)

ServerStart = Struct (
	"mbz" / Bytes(15),
	"accept" / Int8ub,
	"serverIV" / Bytes(16),
	"startTime" / Timestamp,
	"mbz_2" / Bytes(8)
)
	
RequestSession = Struct (
	"command" / Int8ub,
	"ipVersion" / Int8ub,
	"confSender" / Int8ub,
	"confReceiver" /Int8ub,
	"slots" / Int32ub,
	"packets" / Int32ub,
	"senderPort" / Int16ub,
	"receiverPort" / Int16ub,
	"sendAddress" / Int32ub,
	"sendAddress2" / Bytes(12),
	"recvAddress" / Int32ub,
	"recvAddress2" / Bytes(12),
	"sid" / Bytes(16),
	"paddingLength" / Int32ub,
	"startTime" / Timestamp,
	"timeout" / Int64ub,
	"typeP" / Int32ub,
	"mbz" / Bytes(8),
	"hmac" / Bytes(16),
)

AcceptSession = Struct (
	"accept" / Int8ub,
	"mbz" / Bytes(1),
	"port" / Int16ub,
	"sid" / Bytes(16),
	"mbz2" / Bytes(12),
	"hmac" / Bytes(16),
)

StartSessions = Struct (
	"command" / Int8ub,
	"mbz" / Bytes(15),
	"hmac" / Bytes(16),
)

StartAck = Struct (
	"accept" / Int8ub,
	"mbz" / Bytes(15),
	"hmac" / Bytes(16),
)

StopSessions = Struct (
	"command" / Int8ub,
	"accept" / Int8ub,
	"mbz" / Bytes(2),
	"number" / Int32ub,
	"mbz2" / Bytes(8),
)



### UTIL FUNCTIONS ###

def initializeStruct(struct_type):
	'''Initilize fields of a Struct type as zeros'''
	obj = {}
	for field in struct_type._subcons:
		obj[field] = 0
	return obj

TIMEOFFSET = 2208988800    # Time Difference: 1-JAN-1900 to 1-JAN-1970 in seconds

def nowNTP():
	now = time.time()
	return {
		'seconds': int(now) + TIMEOFFSET, 
		'fraction': now - int(now)
	}
	

class NotSupported(Exception):
	pass
	
### CREATING TWAMP MESSAGES TO BE SEND ###

def createServerGreeting():
	msg = initializeStruct(ServerGreeting)
	msg['count'] = 1024
	msg['modes'] = Authentication.Unauthenticated
	msg['challenge'] = os.urandom(16) 
	msg['salt'] = os.urandom(16) 
	log.debug("Sending ServerGreeting msg: %s", msg)
	return ServerGreeting.build(msg)
	
def createServerStart(accept=Accept.AcceptOK):
	msg = initializeStruct(ServerStart)
	msg['accept'] = accept
	msg['startTime'] = nowNTP()
	log.debug("Sending ServerStart msg: %s", msg)
	return ServerStart.build(msg)

def createAcceptSession(port, accept=Accept.AcceptOK):
	msg = initializeStruct(AcceptSession)
	msg['accept'] = accept
	msg['port'] = port
	msg['sid'] = os.urandom(16)
	log.debug("Sending AcceptSession msg: %s", msg)
	return AcceptSession.build(msg)
	
def createStartAck(accept=Accept.AcceptOK):
	msg = initializeStruct(StartAck)
	msg['accept'] = accept
	log.debug("Sending StartAck msg: %s", msg)
	return StartAck.build(msg)
	
	
	
### HANDLING RECEIVED TWAMP MESSAGES ###

def receiveSetupResponse(conn):
	try:
		data = conn.recv(1024)
		msg = None
		try:
			msg = SetupResponse.parse(data)
		except:
			pass
		if msg == None:
			msg = SetupResponseSimple.parse(data)
		log.debug("SetupResponse msg received: %s", msg)
		if msg != None and (msg.mode != Authentication.Unauthenticated):
			raise NotSupported("Unsupported setup mode received: %d", msg.mode)
	except NotSupported as e:
		conn.sendall(createServerStart(accept=Accept.AcceptNotSupported))
		raise e
	except Exception as e:
		log.debug("Message received %s", data)
		conn.sendall(createServerStart(accept=Accept.AcceptInternalError))
		log.exception('Breaking after a failure')
		raise e		
		
def receiveRequestSession(conn):
	try:
		data = conn.recv(1024)
		msg = RequestSession.parse(data)	
		if msg.command != Command.RequestSession:
			raise NotSupported("Unsupported command number received when expecting RequestSession msg: %d", msg.command)
		if msg.ipVersion != 4:
			raise NotSupported("Unsupported ip version received in RequestSession msg: %d", msg.ipVersion)
		log.debug("RequestSession msg received: %s", msg)
		return msg
	except NotSupported as e:
		conn.sendall(createAcceptSession(port=0, accept=Accept.AcceptNotSupported))
		raise e
	except Exception as e:
		log.debug("Message received %s", data)
		conn.sendall(createAcceptSession(port=0, accept=Accept.AcceptInternalError))
		log.exception('Breaking after a failure')
		raise e
	
def receiveStartSessions(conn):
	try:
		data = conn.recv(1024)
		msg = StartSessions.parse(data)
		if msg.command != Command.StartSessions:
			raise NotSupported("Unsupported command number received when expecting StartSessions msg: %d", msg.command)
		log.debug("StartSessions msg received: %s", msg)
	except NotSupported as e:
		conn.sendall(createStartAck(accept=Accept.AcceptNotSupported))
		raise e
	except Exception as e:
		log.debug("Message received %s", data)
		conn.sendall(createStartAck(accept=Accept.AcceptInternalError))
		log.exception('Breaking after a failure')
		raise e
	
def receiveStopSessions(conn):
	data = conn.recv(1024)
	msg = StopSessions.parse(data)
	if msg.command != Command.StopSessions:
		log.exception('Breaking after a failure')
		raise NotSupported("Unsupported command number received when expecting StopSessions msg: %d", msg.command)
	log.debug("StopSessions msg received: %s", msg)
	
def startReflector(upd_port):
	pass


### TWAMP SERVER (EXCHANGING TWAMP CONTROL MESSAGES) ###	
	
class TwampServerHandler(socketserver.BaseRequestHandler):
    def handle(self):
        log.info("Handling the TWAMP control connection from the client: %s", self.client_address)
        self.request.sendall(createServerGreeting())
        
        receiveSetupResponse(self.request)
        self.request.sendall(createServerStart())
        
        sessionReq = receiveRequestSession(self.request)
        udp_port = sessionReq.receiverPort
        #TODO check udp port and other session parameters
        startReflector(TWAMP_TEST_PORT)
        self.request.sendall(createAcceptSession(udp_port))
        
        receiveStartSessions(self.request)
        self.request.sendall(createStartAck())
        
        receiveStopSessions(self.request)
        log.info("Finished the control connection from the client: %s", self.client_address)

def run_twamp_server():
	log.info("Starting TWAMP server on ip: %s and port: %d", TWAMP_CONTROL_IP, TWAMP_CONTROL_PORT)
	try:
		server =	socketserver.TCPServer((TWAMP_CONTROL_IP, TWAMP_CONTROL_PORT), TwampServerHandler)
		server.serve_forever()
	except Exception as e:
		log.exception("Exception in main handler", e)
	finally:
		server.server_close()

def start_twamp_server():
    thread = threading.Thread(target=run_twamp_server)
    thread.daemon = True
    thread.start()

if __name__ == "__main__":
	logging.basicConfig(level="DEBUG")
	logger = logging.getLogger()
	hdlr = logging.FileHandler('/tmp/twamp_server.log')
	hdlr.setFormatter(logging.Formatter('%(asctime)s %(levelname)s %(message)s'))
	logger.addHandler(hdlr) 
	run_twamp_server()
	
	#~ s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

	#~ #Bind socket to local host and port
	#~ try:
		#~ s.bind((TWAMP_CONTROL_IP, TWAMP_CONTROL_PORT))
	#~ except socket.error as msg:
		#~ print('Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
		#~ sys.exit()
		
	#~ print('Socket bind complete')

	#~ #Start listening on socket
	#~ s.listen(10)
	#~ print('Socket now listening')

	#~ #now keep talking with the client
	#~ while 1:
		#~ #wait to accept a connection - blocking call
		#~ conn, addr = s.accept()
		#~ print('Connected with ' + addr[0] + ':' + str(addr[1]))
		
	#~ s.close()
